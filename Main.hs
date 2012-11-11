module Main where

import System
import Control.Monad
import qualified Data.List as List

import Backend.IR.Oprnd (Oprnd (..), Reg (..), getReg)
import Backend.IR.Temp
import qualified Backend.IR.Tree as IRTree
import Backend.X64.Insn
import Backend.X64.Munch
--import qualified Backend.X64.RegAlloc as RegAlloc
import qualified Backend.X64.DataFlow as DataFlow

import Frontend.ObjModel
import Frontend.Parser
import qualified Frontend.IRGen as IRGen

prettifyDataFlow :: [Insn] -> String
prettifyDataFlow insnList = List.intercalate "\n" outputStrList
  where
    duList = map DataFlow.getDefUse insnList
    lvList = DataFlow.getLiveness duList
    outputStrList = map prettify (List.zip3 insnList duList lvList)
    prettify (insn,du,lv) = leftAlign (show insn) 30 ++ ";; " ++ 
      show du ++ "| " ++ show lv
    leftAlign s howMany =
      if length s < howMany
        then leftAlign (s ++ " ") howMany
        else s

main = do
  input <- liftM (!!0) getArgs
  let c = readProg input
  putStrLn $ show c
  case pairToList c of
    ([Symbol "parse-success", prog], _) -> do
      let treeM = IRGen.gen prog
          insnsM = munch treeM
          (tree, insns) = runTempGen $ do 
            tree <- treeM
            insns <- insnsM
            return (tree, insns)
      putStrLn $ show tree
      putStrLn $ prettifyDataFlow insns
    ([Symbol "parse-error", what], _) -> putStrLn $ show what

