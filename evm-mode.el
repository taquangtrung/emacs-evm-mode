;;; evm-mode.el --- Major mode for editing Ethereum EVM bytecode

;; Copyright © 2022, by Ta Quang Trung

;; Author: Ta Quang Trung
;; Version: 0.0.1
;; Created: 29 April 2022
;; Keywords: Ethereum, EVM bytcode
;; Homepage: https://github.com/taquangtrung/emacs-evm-mode

;; This file is not part of GNU Emacs.

;;; License:

;; You can redistribute this program and/or modify it under the terms of the GNU
;; General Public License version 2.

;;; Commentary:

;; short description here

;; full doc on how to use here

;;; Code:

(require 'rx)

(defconst evm-opcodes
  '("add"
    "addmod"
    "address"
    "and"
    "balance"
    "basefee"
    "blockhash"
    "byte"
    "call"
    "callcode"
    "calldatacopy"
    "calldataload"
    "calldatasize"
    "caller"
    "callvalue"
    "chainid"
    "codecopy"
    "codesize"
    "coinbase"
    "create"
    "create2"
    "delegatecall"
    "difficulty"
    "div"
    "dup1"
    "dup10"
    "dup11"
    "dup12"
    "dup13"
    "dup14"
    "dup15"
    "dup16"
    "dup2"
    "dup3"
    "dup4"
    "dup5"
    "dup6"
    "dup7"
    "dup8"
    "dup9"
    "eq"
    "exp"
    "extcodecopy"
    "extcodehash"
    "extcodesize"
    "gas"
    "gaslimit"
    "gasprice"
    "gt"
    "invalid"
    "iszero"
    "jump"
    "jumpdest"
    "jumpi"
    "keccak256"
    "log0"
    "log1"
    "log2"
    "log3"
    "log4"
    "lt"
    "mload"
    "mod"
    "msize"
    "mstore"
    "mstore8"
    "mul"
    "mulmod"
    "not"
    "number"
    "or"
    "origin"
    "pc"
    "pop"
    "push1"
    "push10"
    "push11"
    "push12"
    "push13"
    "push14"
    "push15"
    "push16"
    "push17"
    "push18"
    "push19"
    "push2"
    "push20"
    "push21"
    "push22"
    "push23"
    "push24"
    "push25"
    "push26"
    "push27"
    "push28"
    "push29"
    "push3"
    "push30"
    "push31"
    "push32"
    "push4"
    "push5"
    "push6"
    "push7"
    "push8"
    "push9"
    "return"
    "returndatacopy"
    "returndatasize"
    "revert"
    "sar"
    "sdiv"
    "selfbalance"
    "selfdestruct"
    "sgt"
    "sha3"
    "shl"
    "shr"
    "signextend"
    "sload"
    "slt"
    "smod"
    "sstore"
    "staticcall"
    "stop"
    "sub"
    "swap1"
    "swap10"
    "swap11"
    "swap12"
    "swap13"
    "swap14"
    "swap15"
    "swap16"
    "swap2"
    "swap3"
    "swap4"
    "swap5"
    "swap6"
    "swap7"
    "swap8"
    "swap9"
    "timestamp"
    "xor")
  "List of EVM opcodes ")

;; TODO: check if `assembly' is a preprocessor
(defconst evm-preprocessors
  '("assembly")
  "List of EVM preprocessor")

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Syntax highlighting

(defvar evm-syntax-table
  (let ((syntax-table (make-syntax-table)))
    ;; C++ style comment "// ..."
    (modify-syntax-entry ?\/ ". 124" syntax-table)
    (modify-syntax-entry ?* ". 23b" syntax-table)
    (modify-syntax-entry ?\n ">" syntax-table)
    syntax-table)
  "Syntax table for `EVM' bytecode mode.")

(defvar evm-opcode-regexp
  (concat
   (rx symbol-start)
   (regexp-opt evm-opcodes t)
   (rx symbol-end))
  "Regular expression to match EVM opcodes")

(defvar evm-preprocessor-regexp
  (concat
   (rx symbol-start)
   (regexp-opt evm-preprocessors t)
   (rx symbol-end))
  "Regular expression to match EVM preprocessors")

(defun evm--match-regexp (re limit)
  "Generic regular expression matching wrapper for RE with a given LIMIT."
  (re-search-forward re
                     limit ; search bound
                     t     ; no error, return nil
                     nil   ; do not repeat
                     ))

(defun evm--match-functions (limit)
  "Search the buffer forward until LIMIT matching function names.
Highlight the 1st result."
  (evm--match-regexp
   (concat
    " *\\([a-zA-Z0-9_]+\\) *\(")
   limit))

(defun evm--match-preprocessor (limit)
  "Search the buffer forward until LIMIT matching preprocessor names.
Highlight the 1st result."
  (evm--match-regexp
   (concat
    " *\\([a-zA-Z0-9_]+\\) *\(")
   limit))

(defconst evm-font-lock-keywords
  (list
   `(,evm-opcode-regexp . font-lock-keyword-face)
   `(,evm-preprocessor-regexp . font-lock-preprocessor-face)
   '(evm--match-functions (1 font-lock-function-name-face))
   )
  "EVM font lock keywords.")

;;;;;;;;;;;;;;;;;;;;;
;;; Imenu settings

(defvar evm--imenu-generic-expression
  '(("Subroutine"
     "^\\s-*\\([a-zA-Z0-9_']+\\):\\s-*assembly\\s-*\{"
     1))
  "Regular expression to generate Imenu outline.")

(defun evm--imenu-create-index ()
  "Generate outline of EVM bytecode for imenu-mode."
  (save-excursion
    (imenu--generic-function evm--imenu-generic-expression)))

;;;;;;;;;;;;;;;;;;;;;

;;;###autoload
(define-derived-mode evm-mode prog-mode
  "EVM-mode"
  "Major mode for editing EVM bytecode files"
  :syntax-table evm-syntax-table

  ;; Syntax highlighting
  (setq font-lock-defaults '(evm-font-lock-keywords))

  ;; Indentation
  (setq-local indent-tabs-mode nil)                    ;; using space
  (setq-local indent-line-function 'indent-relative)   ;; indent line relative
  (setq-local indent-region-function '(lambda (x y) ()))    ;; disable indent region

  ;; Set comment command
  (set (make-local-variable 'comment-start) "//")
  (set (make-local-variable 'comment-end) "")
  (set (make-local-variable 'comment-multi-line) nil)
  (set (make-local-variable 'comment-use-syntax) t)

  ;; Configure imenu
  (setq-local imenu-create-index-function 'evm--imenu-create-index)

  (run-hooks 'evm-hook))

;; Binding with *.evm files
(or (assoc "\\.evm$" auto-mode-alist)
    (setq auto-mode-alist (cons '("\\.evm$" . evm-mode) auto-mode-alist)))

;; Finally export the `evm-mode'
(provide 'evm-mode)

;; Local Variables:
;; coding: utf-8
;; End:

;;; evm-mode.el ends here