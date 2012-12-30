import System.IO
import Data.List.Split
import Data.Char
import Data.Bits
import Control.Monad
import UnionFind

import qualified Data.Map as Map
import qualified Data.List
import qualified Data.Set as Set
import Data.Maybe as Maybe
    
file = "clustering2.txt"

-- subsets of size k
combinationsOf 0 _ = [[]]
combinationsOf _ [] = []
combinationsOf k (x:xs) = map (x:) (combinationsOf (k-1) xs) ++ combinationsOf k xs

maxCluster :: Int -> [Int] -> Equivalence Int -> Map.Map Int Int -> Int
maxCluster bits nodes unionFind nodesMap = 
    numberOfComponents $ foldl (\uf (x,y) -> equate x y uf) unionFind (nodesToMerge nodes nodesMap offsets)
    where offsets = map (shiftL 1) [0..(bits - 1)]

nodesToMerge :: [Int] -> Map.Map Int Int -> [Int] -> [(Int, Int)]
nodesToMerge nodes nodesMap offsets = 
    concatMap nodeCombinations (zip [0..] nodes)    
    where nodeCombinations (nodeIndex, node) = zip (repeat nodeIndex) (getNeighbours node)
          getNeighbours node = join . map (maybeToList . findInNodesMap) $ neighbours node
          findInNodesMap neighbour = Map.lookup neighbour nodesMap
          neighbours node = map (xor node) offsets ++ 
                            map (\pair -> xor node ((pair !! 0) .|. (pair !! 1))) (combinationsOf 2 offsets)

-- findMaxClusters :: String -> Int
findMaxClusters fileContents = 
    -- size nodesMap
    -- nodesToMerge nodes nodesMap (offsets bits)
    maxCluster bits nodes unionFind nodesMap
    where (bits,nodes) = process fileContents
          unionFind = (emptyEquivalence (0, length nodes-1)) 
          nodesMap = Map.fromList (zip nodes [0..])

process :: String -> (Int, [Int])
process fileContents = (bits, nodes)
                       where bits = extractBits $ processedFileContents !! 0
                             nodes = Set.toList . Set.fromList . map (toDecimal . trimSpaces) . (drop 1) $ processedFileContents
                             processedFileContents = splitOn "\n" fileContents
                             trimSpaces = filter (not . isSpace)
                             toDecimal = foldr (\c s -> s * 2 + c) 0 . reverse . map digitToInt 
                             extractBits header = read $ (splitOn " " header) !! 1 

main = do     
    withFile file ReadMode (\handle -> do  
        contents <- hGetContents handle     
        (putStrLn . show . findMaxClusters) contents)    