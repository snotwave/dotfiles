;;;; -*- indent-tabs-mode: nil -*-
;;;
;;; swank-clasp.lisp --- SLIME backend for CLASP.
;;;
;;; This code has been placed in the Public Domain.  All warranties
;;; are disclaimed.
;;;

;;; Administrivia

(defpackage swank/clasp
  (:use cl swank/backend))

(in-package swank/clasp)

;; Hard dependencies.
(eval-when (:compile-toplevel :load-toplevel :execute)
  (require 'sockets))

;; Soft dependencies.
(eval-when (:compile-toplevel :load-toplevel :execute)
  (when (probe-file "sys:profile.fas")
    (require :profile)
    (pushnew :profile *features*))
  (when (probe-file "sys:src;lisp;modules;serve-event;")
    (require :serve-event)
    (pushnew :serve-event *features*))
  (when (find-symbol "TEMPORARY-DIRECTORY" "EXT")
    (pushnew :temporary-directory *features*)))

;;; Compatibility tests

(eval-when (:compile-toplevel :load-toplevel :execute)
  ;; xref support (2.4)
  (defun clasp-with-xref-p ()
   (with-symbol 'who-calls 'ext)))

;;; Swank-mop

(eval-when (:compile-toplevel :load-toplevel :execute)
  (import-swank-mop-symbols :clos nil))

(defimplementation gray-package-name ()
  "GRAY")


;;;; TCP Server

(defimplementation preferred-communication-style ()
  :spawn
#|  #+threads :spawn
  #-threads nil
|#
  )

(defun resolve-hostname (name)
  (car (sb-bsd-sockets:host-ent-addresses
        (sb-bsd-sockets:get-host-by-name name))))

(defimplementation create-socket (host port &key backlog)
  (let ((socket (make-instance 'sb-bsd-sockets:inet-socket
			       :type :stream
			       :protocol :tcp)))
    (setf (sb-bsd-sockets:sockopt-reuse-address socket) t)
    (handler-bind
        ((SB-BSD-SOCKETS:ADDRESS-IN-USE-ERROR (lambda (err)
                                                (declare (ignore err))
                                               (invoke-restart 'use-value))))
      (sb-bsd-sockets:socket-bind socket (resolve-hostname host) port))
    (sb-bsd-sockets:socket-listen socket (or backlog 5))
    socket))

(defimplementation local-port (socket)
  (nth-value 1 (sb-bsd-sockets:socket-name socket)))

(defimplementation close-socket (socket)
  (sb-bsd-sockets:socket-close socket))

(defimplementation accept-connection (socket
                                      &key external-format
                                      buffering timeout)
  (declare (ignore timeout))
  (sb-bsd-sockets:socket-make-stream (accept socket)
                                     :output t
                                     :input t
                                     :buffering (ecase buffering
                                                  ((t) :full)
                                                  ((nil) :none)
                                                  (:line :line))
                                     :element-type (if external-format
                                                       'character 
                                                       '(unsigned-byte 8))
                                     :external-format external-format))
(defun accept (socket)
  "Like socket-accept, but retry on EAGAIN."
  (loop (handler-case
            (return (sb-bsd-sockets:socket-accept socket))
          (sb-bsd-sockets:interrupted-error ()))))

(defimplementation socket-fd (socket)
  (etypecase socket
    (fixnum socket)
    (two-way-stream (socket-fd (two-way-stream-input-stream socket)))
    (sb-bsd-sockets:socket (sb-bsd-sockets:socket-file-descriptor socket))
    (file-stream (ext:file-stream-file-descriptor socket))))

(defvar *external-format-to-coding-system*
  '((:latin-1
     "latin-1" "latin-1-unix" "iso-latin-1-unix" 
     "iso-8859-1" "iso-8859-1-unix")
    (:utf-8 "utf-8" "utf-8-unix")))

(defun external-format (coding-system)
  (or (car (rassoc-if (lambda (x) (member coding-system x :test #'equal))
                      *external-format-to-coding-system*))
      (find coding-system (ext:all-encodings) :test #'string-equal)))

(defimplementation find-external-format (coding-system)
  #+unicode (external-format coding-system)
  ;; Without unicode support, CLASP uses the one-byte encoding of the
  ;; underlying OS, and will barf on anything except :DEFAULT.  We
  ;; return NIL here for known multibyte encodings, so
  ;; SWANK:CREATE-SERVER will barf.
  #-unicode (let ((xf (external-format coding-system)))
              (if (member xf '(:utf-8))
                  nil
                  :default)))


;;;; Unix Integration

;;; If CLASP is built with thread support, it'll spawn a helper thread
;;; executing the SIGINT handler. We do not want to BREAK into that
;;; helper but into the main thread, though. This is coupled with the
;;; current choice of NIL as communication-style in so far as CLASP's
;;; main-thread is also the Slime's REPL thread.

#+clasp-working
(defimplementation call-with-user-break-handler (real-handler function)
  (let ((old-handler #'si:terminal-interrupt))
    (setf (symbol-function 'si:terminal-interrupt)
          (make-interrupt-handler real-handler))
    (unwind-protect (funcall function)
      (setf (symbol-function 'si:terminal-interrupt) old-handler))))

#+threads
(defun make-interrupt-handler (real-handler)
  (let ((main-thread (find 'si:top-level (mp:all-processes)
                           :key #'mp:process-name)))
    #'(lambda (&rest args)
        (declare (ignore args))
        (mp:interrupt-process main-thread real-handler))))

#-threads
(defun make-interrupt-handler (real-handler)
  #'(lambda (&rest args)
      (declare (ignore args))
      (funcall real-handler)))


(defimplementation getpid ()
  (clasp-posix:getpid))

(defimplementation set-default-directory (directory)
  (ext:chdir (namestring directory))
  (setf *default-pathname-defaults* (pathname (ext:getcwd)))
  (default-directory))

(defimplementation default-directory ()
  (namestring (ext:getcwd)))

(defimplementation quit-lisp ()
  (sys:quit))



;;; Instead of busy waiting with communication-style NIL, use select()
;;; on the sockets' streams.
#+serve-event
(progn
  (defun poll-streams (streams timeout)
    (let* ((serve-event::*descriptor-handlers*
            (copy-list serve-event::*descriptor-handlers*))
           (active-fds '())
           (fd-stream-alist
            (loop for s in streams
                  for fd = (socket-fd s)
                  collect (cons fd s)
                  do (serve-event:add-fd-handler fd :input
                                                 #'(lambda (fd)
                                                     (push fd active-fds))))))
      (serve-event:serve-event timeout)
      (loop for fd in active-fds collect (cdr (assoc fd fd-stream-alist)))))

  (defimplementation wait-for-input (streams &optional timeout)
    (assert (member timeout '(nil t)))
    (loop
       (cond ((check-slime-interrupts) (return :interrupt))
             (timeout (return (poll-streams streams 0)))
             (t
              (when-let (ready (poll-streams streams 0.2))
                        (return ready))))))  

) ; #+serve-event (progn ...

#-serve-event
(defimplementation wait-for-input (streams &optional timeout)
  (assert (member timeout '(nil t)))
  (loop
   (cond ((check-slime-interrupts) (return :interrupt))
         (timeout (return (remove-if-not #'listen streams)))
         (t
          (let ((ready (remove-if-not #'listen streams)))
            (if ready (return ready))
            (sleep 0.1))))))


;;;; Compilation

(defvar *buffer-name* nil)
(defvar *buffer-start-position*)

(defun condition-severity (condition)
  (etypecase condition
    (cmp:redefined-function-warning :redefinition)
    (style-warning                  :style-warning)
    (warning                        :warning)
    (reader-error                   :read-error)
    (error                          :error)))

(defun %condition-location (origin)
  ;; NOTE: If we're compiling in a buffer, the origin
  ;; will already be set up with the offset correctly
  ;; due to the :source-debug parameters from
  ;; swank-compile-string (below).
  (make-file-location
   (sys:file-scope-pathname
    (sys:file-scope origin))
   (sys:source-pos-info-filepos origin)))

(defun condition-location (origin)
  (typecase origin
    (null (make-error-location "No error location available"))
    (cons (%condition-location (car origin)))
    (t (%condition-location origin))))

(defun signal-compiler-condition (condition origin)
  (signal 'compiler-condition
          :original-condition condition
          :severity (condition-severity condition)
          :message (princ-to-string condition)
          :location (condition-location origin)))

(defun handle-compiler-condition (condition)
  ;; First resignal warnings, so that outer handlers - which may choose to
  ;; muffle this - get a chance to run.
  (when (typep condition 'warning)
    (signal condition))
  (signal-compiler-condition (cmp:deencapsulate-compiler-condition condition)
                             (cmp:compiler-condition-origin condition)))

(defimplementation call-with-compilation-hooks (function)
  (handler-bind
      (((or error warning) #'handle-compiler-condition))
    (funcall function)))

(defun mkstemp (name)
  (ext:mkstemp #+temporary-directory
               (namestring (make-pathname :name name
                                          :defaults (ext:temporary-directory)))
               #-temporary-directory
               (concatenate 'string "tmp:" name)))

(defimplementation swank-compile-file (input-file output-file
                                       load-p external-format
                                       &key policy)
  (declare (ignore policy))
  (multiple-value-bind (fasl warnings-p failure-p)
      (with-compilation-hooks ()
        (compile-file input-file :output-file output-file
                                 :external-format external-format))
      (values fasl warnings-p
              (or failure-p
                  (when load-p
                    (not (load fasl)))))))

(defvar *tmpfile-map* (make-hash-table :test #'equal))

(defun note-buffer-tmpfile (tmp-file buffer-name)
  ;; EXT:COMPILED-FUNCTION-FILE below will return a namestring.
  (let ((tmp-namestring (namestring (truename tmp-file))))
    (setf (gethash tmp-namestring *tmpfile-map*) buffer-name)
    tmp-namestring))

(defun tmpfile-to-buffer (tmp-file)
  (gethash tmp-file *tmpfile-map*))

(defimplementation swank-compile-string (string &key buffer position filename line column policy)
  (declare (ignore column policy)) ;; We may use column in the future
  (with-compilation-hooks ()
    (let ((*buffer-name* buffer)        ; for compilation hooks
          (*buffer-start-position* position))
      (let ((tmp-file (mkstemp "clasp-swank-tmpfile-"))
            (fasl-file)
            (warnings-p)
            (failure-p))
        (unwind-protect
             (progn
               (with-open-file (tmp-stream tmp-file :direction :output
                                                    :if-exists :overwrite)
                 (write-string string tmp-stream))
               (multiple-value-setq (fasl-file warnings-p failure-p)
                 (let ((truename (or filename (note-buffer-tmpfile tmp-file buffer))))
                   (compile-file tmp-file
                                 :source-debug-pathname (pathname truename)
                                 ;; emacs numbers are 1-based instead of 0-based,
                                 ;; so we have to subtract
                                 :source-debug-lineno (1- line)
                                 :source-debug-offset (1- position)))))
          (when fasl-file (load fasl-file))
          (when (probe-file tmp-file)
            (delete-file tmp-file))
          (when fasl-file
            (delete-file fasl-file)))
        (not failure-p)))))

;;;; Documentation

(defimplementation arglist (name)
  (multiple-value-bind (arglist foundp)
      (ext:function-lambda-list name)     ;; Uses bc-split
    (if foundp arglist :not-available)))

(defimplementation function-name (f)
  (typecase f
    (generic-function (clos:generic-function-name f))
    (function (ext:compiled-function-name f))))

;; FIXME
(defimplementation macroexpand-all (form &optional env)
  (declare (ignore env))
  (macroexpand form))

;;; modified from sbcl.lisp
(defimplementation collect-macro-forms (form &optional environment)
  (let ((macro-forms '())
        (compiler-macro-forms '())
        (function-quoted-forms '()))
    (cmp:code-walk
     (lambda (form environment)
       (when (and (consp form)
                  (symbolp (car form)))
         (cond ((eq (car form) 'function)
                (push (cadr form) function-quoted-forms))
               ((member form function-quoted-forms)
                nil)
               ((macro-function (car form) environment)
                (push form macro-forms))
               ((not (eq form (sys:compiler-macroexpand-1 form environment)))
                (push form compiler-macro-forms))))
       form)
     form environment)
    (values macro-forms compiler-macro-forms)))





(defimplementation describe-symbol-for-emacs (symbol)
  (let ((result '()))
    (flet ((frob (type boundp)
             (when (funcall boundp symbol)
               (let ((doc (describe-definition symbol type)))
                 (setf result (list* type doc result))))))
      (frob :VARIABLE #'boundp)
      (frob :FUNCTION #'fboundp)
      (frob :CLASS (lambda (x) (find-class x nil))))
    result))

(defimplementation describe-definition (name type)
  (case type
    (:variable (documentation name 'variable))
    (:function (documentation name 'function))
    (:class (documentation name 'class))
    (t nil)))

(defimplementation type-specifier-p (symbol)
  (or (subtypep nil symbol)
      (not (eq (type-specifier-arglist symbol) :not-available))))

;;; XREF

#+#.(swank/clasp::clasp-with-xref-p)
(macrolet ((defxref (name &optional (fname name))
             `(defimplementation ,name (what)
                (let ((r (,(find-symbol (symbol-name fname) "EXT")
                          what)))
                  (loop for (fname . spi) in r
                        collect (list fname (translate-spi spi)))))))
  (defxref who-calls)
  (defxref who-binds)
  (defxref who-sets)
  (defxref who-references)
  (defxref who-macroexpands)
  (defxref who-specializes who-specializes-directly)
  (defxref list-callers)
  (defxref list-callees))


;;; Debugging

(defun make-invoke-debugger-hook (hook)
  (when hook
    #'(lambda (condition old-hook)
        ;; Regard *debugger-hook* if set by user.
        (if *debugger-hook*
            nil         ; decline, *DEBUGGER-HOOK* will be tried next.
            (funcall hook condition old-hook)))))

(defimplementation install-debugger-globally (function)
  (setq *debugger-hook* function)
  (setq ext:*invoke-debugger-hook* (make-invoke-debugger-hook function)))

(defimplementation call-with-debugger-hook (hook fun)
  (let ((*debugger-hook* hook)
        (ext:*invoke-debugger-hook* (make-invoke-debugger-hook hook)))
    (funcall fun)))

(defvar *backtrace* '())

;;; Commented out; it's not clear this is a good way of doing it. In
;;; particular because it makes errors stemming from this file harder
;;; to debug, and given the "young" age of CLASP's swank backend, that's
;;; a bad idea.

;; (defun in-swank-package-p (x)
;;   (and
;;    (symbolp x)
;;    (member (symbol-package x)
;;            (list #.(find-package :swank)
;;                  #.(find-package :swank/backend)
;;                  #.(ignore-errors (find-package :swank-mop))
;;                  #.(ignore-errors (find-package :swank-loader))))
;;    t))

;; (defun is-swank-source-p (name)
;;   (setf name (pathname name))
;;   (pathname-match-p
;;    name
;;    (make-pathname :defaults swank-loader::*source-directory*
;;                   :name (pathname-name name)
;;                   :type (pathname-type name)
;;                   :version (pathname-version name))))

;; (defun is-ignorable-fun-p (x)
;;   (or
;;    (in-swank-package-p (frame-name x))
;;    (multiple-value-bind (file position)
;;        (ignore-errors (si::bc-file (car x)))
;;      (declare (ignore position))
;;      (if file (is-swank-source-p file)))))

(defimplementation call-with-debugging-environment (debugger-loop-fn)
  (declare (type function debugger-loop-fn))
  (clasp-debug:with-stack (stack)
    (let ((*backtrace* (clasp-debug:list-stack stack)))
      (funcall debugger-loop-fn))))

(defimplementation compute-backtrace (start end)
  (subseq *backtrace* start
          (and (numberp end)
               (min end (length *backtrace*)))))

(defun frame-from-number (frame-number)
  (elt *backtrace* frame-number))

(defimplementation print-frame (frame stream)
  (clasp-debug:prin1-frame-call frame stream))

(defun translate-spi (spi)
  (if spi
      (let ((pathname (clasp-debug:code-source-line-pathname spi)))
        (if pathname
            (make-location (list :file (namestring (translate-logical-pathname pathname)))
                           (list :line (clasp-debug:code-source-line-line-number spi))
                           '(:align t))
            nil))
      nil))

(defimplementation frame-source-location (frame-number)
  (or (translate-spi
       (clasp-debug:frame-source-position
        (frame-from-number frame-number)))
      `(:error ,(format nil "No source for frame: ~a" frame-number))))

(defimplementation frame-locals (frame-number)
  (loop for (var . value)
          in (clasp-debug:frame-locals (frame-from-number frame-number))
        for i from 0
        collect (list :name var :id i :value value)))

(defimplementation frame-var-value (frame-number var-number)
  (let* ((frame (frame-from-number frame-number))
         (locals (clasp-debug:frame-locals frame)))
    (cdr (nth var-number locals))))

(defimplementation disassemble-frame (frame-number)
  (clasp-debug:disassemble-frame (frame-from-number frame-number)))

(defimplementation eval-in-frame (form frame-number)
  (let* ((frame (frame-from-number frame-number)))
    (eval
     `(let (,@(loop for (var . value)
                      in (clasp-debug:frame-locals frame)
                    collect `(,var ',value)))
        (progn ,form)))))

(defimplementation activate-stepping (frame)
  (declare (ignore frame))
  (core:set-breakstep))

(defimplementation sldb-stepper-condition-p (condition)
  (typep condition 'clasp-debug:step-form))

(defimplementation sldb-step-into ()
  (invoke-restart 'clasp-debug:step-into))

(defimplementation sldb-step-next ()
  (invoke-restart 'clasp-debug:step-over))

(defimplementation sldb-step-out ()
  ;; FIXME: This stops stepping entirely. Clasp does not have step out yet.
  (invoke-restart 'continue))

#+clasp-working
(defimplementation gdb-initial-commands ()
  ;; These signals are used by the GC.
  #+linux '("handle SIGPWR  noprint nostop"
            "handle SIGXCPU noprint nostop"))

(defimplementation command-line-args ()
  (loop for n below (ext:argc) collect (ext:argv n)))


;;;; Inspector

;;; FIXME: Would be nice if it was possible to inspect objects
;;; implemented in C.


;;;; Definitions

(defun make-file-location (file file-position)
  ;; File positions in CL start at 0, but Emacs' buffer positions
  ;; start at 1. We specify (:ALIGN T) because the positions comming
  ;; from CLASP point at right after the toplevel form appearing before
  ;; the actual target toplevel form; (:ALIGN T) will DTRT in that case.
  (make-location `(:file ,(namestring (translate-logical-pathname file)))
                 `(:position ,(1+ file-position))
                 `(:align t)))

(defun make-buffer-location (buffer-name start-position &optional (offset 0))
  (make-location `(:buffer ,buffer-name)
                 `(:offset ,start-position ,offset)
                 `(:align t)))

(defun translate-location (location)
  (make-location (list :file (namestring (translate-logical-pathname (ext:source-location-pathname location))))
                 (list :position (ext:source-location-offset location))
                 '(:align t)))

(defun make-dspec (name location)
  (list* (ext:source-location-definer location)
         name
         (ext:source-location-description location)))

(defimplementation find-definitions (name)
  (loop for kind in ext:*source-location-kinds*
        for locations = (ext:source-location name kind)
        when locations
          nconc (loop for location in locations
                      collect (list (make-dspec name location)
                                    (translate-location location)))))

(defun source-location (object)
  (let ((location (ext:source-location object t)))
    (when location
      (translate-location (car location)))))

(defimplementation find-source-location (object)
  (or (source-location object)
      (make-error-location "Source definition of ~S not found." object)))


;;;; Profiling

;;;; as clisp and ccl

(defimplementation profile (fname)
  (eval `(swank-monitor:monitor ,fname)))         ;monitor is a macro

(defimplementation profiled-functions ()
  swank-monitor:*monitored-functions*)

(defimplementation unprofile (fname)
  (eval `(swank-monitor:unmonitor ,fname)))       ;unmonitor is a macro

(defimplementation unprofile-all ()
  (swank-monitor:unmonitor))

(defimplementation profile-report ()
  (swank-monitor:report-monitoring))

(defimplementation profile-reset ()
  (swank-monitor:reset-all-monitoring))

(defimplementation profile-package (package callers-p methods)
  (declare (ignore callers-p methods))
  (swank-monitor:monitor-all package))


;;;; Threads

#+threads
(progn
  (defvar *thread-id-counter* 0)

  (defparameter *thread-id-map* (make-hash-table))

  (defvar *thread-id-map-lock*
    (mp:make-lock :name "thread id map lock"))

  (defimplementation spawn (fn &key name)
    (mp:process-run-function name fn))

  (defimplementation thread-id (target-thread)
    (block thread-id
      (mp:with-lock (*thread-id-map-lock*)
        ;; Does TARGET-THREAD have an id already?
        (maphash (lambda (id thread-pointer)
                   (let ((thread (ext:weak-pointer-value thread-pointer)))
                     (cond ((not thread)
                            (remhash id *thread-id-map*))
                           ((eq thread target-thread)
                            (return-from thread-id id)))))
                 *thread-id-map*)
        ;; TARGET-THREAD not found in *THREAD-ID-MAP*
        (let ((id (incf *thread-id-counter*))
              (thread-pointer (ext:make-weak-pointer target-thread)))
          (setf (gethash id *thread-id-map*) thread-pointer)
          id))))

  (defimplementation find-thread (id)
    (mp:with-lock (*thread-id-map-lock*)
      (let* ((thread-ptr (gethash id *thread-id-map*))
             (thread (and thread-ptr (ext:weak-pointer-value thread-ptr))))
        (unless thread
          (remhash id *thread-id-map*))
        thread)))

  (defimplementation thread-name (thread)
    (mp:process-name thread))

  (defimplementation thread-status (thread)
    (if (mp:process-active-p thread)
        "RUNNING"
        "STOPPED"))

  (defimplementation make-lock (&key name)
    (mp:make-recursive-mutex name))

  (defimplementation call-with-lock-held (lock function)
    (declare (type function function))
    (mp:with-lock (lock) (funcall function)))

  (defimplementation current-thread ()
    mp:*current-process*)

  (defimplementation all-threads ()
    (mp:all-processes))

  (defimplementation interrupt-thread (thread fn)
    (mp:interrupt-process thread fn))

  (defimplementation kill-thread (thread)
    (mp:process-kill thread))

  (defimplementation thread-alive-p (thread)
    (mp:process-active-p thread))

  (defvar *mailbox-lock* (mp:make-lock :name "mailbox lock"))
  (defvar *mailboxes* (list))
  (declaim (type list *mailboxes*))

  (defstruct (mailbox (:conc-name mailbox.))
    thread
    (mutex (mp:make-lock :name "SLIMELCK"))
    (cvar  (mp:make-condition-variable))
    (queue '() :type list))

  (defun mailbox (thread)
    "Return THREAD's mailbox."
    (mp:with-lock (*mailbox-lock*)
      (or (find thread *mailboxes* :key #'mailbox.thread)
          (let ((mb (make-mailbox :thread thread)))
            (push mb *mailboxes*)
            mb))))

  (defimplementation wake-thread (thread)
    (let* ((mbox (mailbox thread))
           (mutex (mailbox.mutex mbox)))
      (mp:with-lock (mutex)
        (mp:condition-variable-broadcast (mailbox.cvar mbox)))))
  
  (defimplementation send (thread message)
    (let* ((mbox (mailbox thread))
           (mutex (mailbox.mutex mbox)))
      (mp:with-lock (mutex)
        (setf (mailbox.queue mbox)
              (nconc (mailbox.queue mbox) (list message)))
        (mp:condition-variable-broadcast (mailbox.cvar mbox)))))

  
  (defimplementation receive-if (test &optional timeout)
    (let* ((mbox (mailbox (current-thread)))
           (mutex (mailbox.mutex mbox)))
      (assert (or (not timeout) (eq timeout t)))
      (loop
         (check-slime-interrupts)
         (mp:with-lock (mutex)
           (let* ((q (mailbox.queue mbox))
                  (tail (member-if test q)))
             (when tail
               (setf (mailbox.queue mbox) (nconc (ldiff q tail) (cdr tail)))
               (return (car tail))))
           (when (eq timeout t) (return (values nil t))) 
           (mp:condition-variable-wait (mailbox.cvar mbox) mutex) ; timedwait 0.2
           (sys:check-pending-interrupts)))))

  ) ; #+threads (progn ...


(defmethod emacs-inspect ((object sys:cxx-object))
  (let ((encoded (sys:encode object)))
    (loop for (key . value) in encoded
       append (list (string key) ": " (list :value value) (list :newline)))))

(defmethod emacs-inspect ((object sys:vaslist))
  (emacs-inspect (sys:list-from-vaslist object)))

;;; Packages

#+package-local-nicknames
(defimplementation package-local-nicknames (package)
  (ext:package-local-nicknames package))

;;; Floating point

(defimplementation float-nan-p (float)
  (ext:float-nan-p float))

(defimplementation float-infinity-p (float)
  (ext:float-infinity-p float))
