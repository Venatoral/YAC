module Main where

import System
import Control.Monad
import qualified Data.List as List

import Backend.IR.IROp (IROp (..), Reg (..), getReg)
import Backend.IR.Temp
import qualified Backend.IR.Tree as IRTree

import Backend.X64.Insn
import Backend.X64.Munch
import Backend.X64.DataFlow
import Backend.X64.FlowGraph
import Backend.X64.GraphBuilder
import Backend.X64.RegAlloc
import Backend.X64.Frame

import Frontend.ObjModel
import Frontend.Parser
--import Frontend.Rewrite
import qualified Frontend.IRGen as IRGen

prettifyInsnOnly :: Show a => [a] -> String
prettifyInsnOnly insnList = List.intercalate "\n" (map show insnList)

visualize1 :: Cell -> IO ()
visualize1 prog = do
  let output = runTempGen $ do 
        tree <- IRGen.gen prog
        insns <- munch tree
        graph <- buildGraph insns
        let graph' = runDefUse graph
            iterLiveness g n = if g' == g
              then (g, n)
              else iterLiveness g' (n+1)
              where
                g' = runLiveness g
        let (graph2, niter) = iterLiveness graph' 0
            insns' = toTrace graph2
        runFrameGen $ do
          insns'' <- alloc insns'
          insns'' <- insertProAndEpilogue insns''
          insns'' <- formatOutput insns''
          return insns''
  -- putStrLn $ "\t.ir-tree\n" ++ show tree
  -- putStrLn $ "\t.insn\n" ++ prettifyInsnOnly insns
  -- putStrLn $ "\t.graph\n" ++ show graph
  -- putStrLn $ "\t.graph#" ++ show niter ++ "\n" ++ show graph'
  -- putStrLn $ "\t.insn'\n" ++ prettifyInsnOnly insns'
  -- putStrLn $ "\t.regalloc-insn\n" ++ prettifyInsnOnly raInsn
  putStrLn output

main = do
  input <- getContents
  let (List c) = readProg input
  --putStrLn $ "\t.parse-result\n" ++ show (List c)
  case c of
    [Symbol "parse-success", prog] -> visualize1 prog
    [Symbol "parse-error", what] -> putStrLn $ show what

