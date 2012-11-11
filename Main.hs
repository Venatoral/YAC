module Main where

import System
import Control.Monad
import qualified Data.List as List

import Backend.IR.Oprnd (Oprnd (..), Reg (..), getReg)
import Backend.IR.Temp
import qualified Backend.IR.Tree as IRTree
import Backend.X64.Insn
import Backend.X64.Munch
import Backend.X64.RegAlloc
--import qualified Backend.X64.RegAlloc as RegAlloc
import Backend.X64.DataFlow

import Frontend.ObjModel
import Frontend.Parser
import qualified Frontend.IRGen as IRGen

prettifyDataFlow :: [Insn] -> String
prettifyDataFlow insnList = List.intercalate "\n" outputStrList
  where
    duList = map getDefUse insnList
    lvList = getLiveness duList
    outputStrList = map prettify (List.zip3 insnList duList lvList)
    prettify (insn,du,lv) = leftAlign (show insn) 30 ++ ";; " ++ 
      show du ++ "| " ++ show lv
    leftAlign s howMany =
      if length s < howMany
        then leftAlign (s ++ " ") howMany
        else s

main = do
  input <- getContents
  let c = readProg input
  putStrLn $ "\t.parse-result\n" ++ show c
  case pairToList c of
    ([Symbol "parse-success", prog], _) -> do
      let (tree, insns) = runTempGen $ do 
            tree <- IRGen.gen prog
            insns <- munch tree
            return (tree, insns)
      putStrLn $ "\t.ir-tree\n" ++ show tree
      putStrLn $ "\t.insn\n" ++ prettifyDataFlow insns
      putStrLn $ "\t.live-range\n" ++ show (
        getLiveRange (getLiveness (map getDefUse insns)))
    ([Symbol "parse-error", what], _) -> putStrLn $ show what

