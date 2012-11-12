module Backend.IR.Tree (
  Tree(..)
) where

import Backend.IR.IROp

data Tree = Leaf IROp
          | Seq Tree Tree
          | Add Tree Tree
          | Move Tree Tree
          | Deref Tree
          | Nop
  deriving (Eq)

instance Show Tree where
  show (Leaf op) = show op
  show (Seq t0 t1) = show t0 ++ "\n" ++ show t1
  show (Add t0 t1) = show t0 ++ " + " ++ show t1
  show (Move t0 t1) = show t0 ++ " := " ++ show t1
  show (Deref t) = "*(" ++ show t ++ ")"
  show Nop = "nop"

