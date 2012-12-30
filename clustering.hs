import System.IO
import Data.List.Split
import Data.Char
import Data.Bits
import qualified Control.Monad as Monad
-- import UnionFind
import Leaders

import qualified Data.Map as Map
import qualified Data.Set as Set
import qualified Data.List as List
import Data.Maybe as Maybe
    
-- subsets of size k
combinationsOf 0 _ = [[]]
combinationsOf _ [] = []
combinationsOf k (x:xs) = map (x:) (combinationsOf (k-1) xs) ++ combinationsOf k xs

maxCluster :: Int -> [Int] -> UnionSet Int -> Map.Map Int Int -> Int
maxCluster bits nodes unionFind nodesMap = 
    numberOfComponents $ foldl (\uf (x,y) -> Leaders.union uf x y ) unionFind (nodesToMerge nodes nodesMap offsets)
    where offsets = map (shiftL 1) [0..(bits - 1)]

nodesToMerge :: [Int] -> Map.Map Int Int -> [Int] -> [(Int, Int)]
nodesToMerge nodes nodesMap offsets = 
    List.sort . Set.toList . Set.fromList . map smallestIdFirst . concatMap nodeCombinations $ (zip [0..] nodes)    
    -- List.sort . map smallestIdFirst . concatMap nodeCombinations $ (zip [0..] nodes)    
    where nodeCombinations (nodeIndex, node) = zip (repeat nodeIndex) (getNeighbours node)
          getNeighbours node = Monad.join . map (maybeToList . findInNodesMap) $ neighbours node
          findInNodesMap neighbour = Map.lookup neighbour nodesMap
          neighbours node = map (xor node) offsets ++ 
                            map (\pair -> xor node ((pair !! 0) .|. (pair !! 1))) (combinationsOf 2 offsets)
          smallestIdFirst (id1, id2) = if id1 > id2 then (id2, id1) else (id1, id2)

-- findMaxClusters :: String -> Int
findMaxClusters fileContents = 
    -- size nodesMap
    -- nodesToMerge nodes nodesMap (map (shiftL 1) [0..(bits - 1)])
    maxCluster bits nodes unionFind nodesMap
    where (bits,nodes) = process fileContents
          unionFind = (create (0, length nodes-1)) 
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
    withFile "clustering2.txt" ReadMode (\handle -> do  
        contents <- hGetContents handle     
        (putStrLn . show . findMaxClusters) contents)    