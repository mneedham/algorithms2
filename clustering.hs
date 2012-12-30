import System.IO
import Data.List.Split
import Data.Char
import Data.Bits
import Control.Monad
import UnionFind

import Data.Map
import Data.List
import Data.Maybe
import Data.Set
    
file = "clustering2.txt"

-- subsets of size k
combinationsOf 0 _ = [[]]
combinationsOf _ [] = []
combinationsOf k (x:xs) = Prelude.map (x:) (combinationsOf (k-1) xs) ++ combinationsOf k xs

extractBits :: String -> Int
extractBits header = read $ (splitOn " " header) !! 1 

toDecimal :: String -> Int
toDecimal = Prelude.foldr (\c s -> s * 2 + c) 0 . reverse . Prelude.map digitToInt 

trimSpaces :: String -> String
trimSpaces = Prelude.filter (not . isSpace)

offsets :: Int -> [Int]
offsets bits = Prelude.map (shiftL 1) [0..(bits - 1)]

process :: String -> (Int, [Int])
process fileContents = (bits, nodes)
    where bits = extractBits $ processedFileContents !! 0
          nodes = (Data.Set.toList . Data.Set.fromList) $ Prelude.map (toDecimal . trimSpaces) . (drop 1) $ processedFileContents
          processedFileContents = splitOn "\n" fileContents

maxCluster :: Int -> [Int] -> Equivalence Int -> Map Int Int -> Int
maxCluster bits nodes unionFind nodesMap = 
    numberOfComponents $ Data.List.foldl (\uf (x,y) -> equate x y uf) unionFind (nodesToMerge nodes nodesMap (offsets bits))

nodesToMerge :: [Int] -> Map Int Int -> [Int] -> [(Int, Int)]
nodesToMerge nodes nodesMap offsets = 
    Prelude.concatMap nodeCombinations (zip [0..] nodes)    
    where nodeCombinations (nodeIndex, node) = zip (repeat nodeIndex) (getNeighbours node)
          getNeighbours node = join . Prelude.map (maybeToList . findInNodesMap) $ neighbours node
          findInNodesMap neighbour = Data.Map.lookup neighbour nodesMap
          neighbours node = Prelude.map (xor node) offsets ++ 
                            Prelude.map (\pair -> xor node ((pair !! 0) .|. (pair !! 1))) (combinationsOf 2 offsets)

-- findMaxClusters :: String -> Int
findMaxClusters fileContents = 
    -- size nodesMap
    -- nodesToMerge nodes nodesMap (offsets bits)
    maxCluster bits nodes unionFind nodesMap
    where (bits,nodes) = process fileContents
          unionFind = (emptyEquivalence (0, length nodes-1)) 
          nodesMap = Data.Map.fromList (zip nodes [0..])

main = do     
    withFile file ReadMode (\handle -> do  
        contents <- hGetContents handle     
        (putStrLn . show . findMaxClusters) contents)    