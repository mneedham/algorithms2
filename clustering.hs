import System.IO
import Data.List.Split
import Data.Char
import Data.Bits
import qualified Control.Monad as Monad
-- import UnionFind
-- import Leaders
import MutableLeaders

import qualified Data.Map as Map
import qualified Data.Set as Set
import qualified Data.List as List
import qualified Data.Maybe as Maybe

import Debug.Trace

import Data.Array.IO
import Data.Array.MArray
import Data.Array
    
-- http://www.polyomino.f2s.com/david/haskell/hs/CombinatoricsGeneration.hs.txt
-- subsets of size k
combinationsOf 0 _ = [[]]
combinationsOf _ [] = []
combinationsOf k (x:xs) = map (x:) (combinationsOf (k-1) xs) ++ combinationsOf k xs

-- maxCluster :: Int -> [Int] -> UnionSet Int  -> Map.Map Int Int -> Int
maxCluster :: Int -> [Int] -> IO (IOArray Int Int)  -> Map.Map Int Int -> IO Int
-- maxCluster :: Int -> [Int] -> Equivalence Int -> Map.Map Int Int -> Int
maxCluster bits nodes unionFind nodesMap = 
    -- numberOfComponents $ foldl (\uf (x,y) -> equate x y uf) unionFind (nodesToMerge nodes nodesMap offsets)
    -- numberOfComponents $ foldl (\uf (x,y) -> Leaders.union uf x y) unionFind (nodesToMerge nodes nodesMap offsets)    
    numberOfComponents $ foldl (\uf (x,y) -> MutableLeaders.union uf x y) unionFind (nodesToMerge nodes nodesMap offsets)        
    where offsets = map (shiftL 1) [0..(bits - 1)]

nodesToMerge :: [Int] -> Map.Map Int Int -> [Int] -> [(Int, Int)]
nodesToMerge nodes nodesMap offsets = 
    List.sort . Set.toList . Set.fromList . map smallestIdFirst . concatMap nodeCombinations $ (zip [0..] nodes)     
    where nodeCombinations (nodeIndex, node) = zip (repeat nodeIndex) (getNeighbours node)
          getNeighbours node = Monad.join . map (Maybe.maybeToList . findInNodesMap) $ neighbours node
          findInNodesMap neighbour = Map.lookup neighbour nodesMap
          neighbours node = map (xor node) offsets ++ map (\(x:y:_) -> xor node (x .|. y)) (combinationsOf 2 offsets)
          smallestIdFirst (id1, id2) = if id1 > id2 then (id2, id1) else (id1, id2)

-- findMaxClusters :: String -> Int
findMaxClusters fileContents = 
    -- size nodesMap
    -- nodesToMerge nodes nodesMap (map (shiftL 1) [0..(bits - 1)])
    maxCluster bits nodes unionFind nodesMap
    where (bits,nodes) = process fileContents
          -- unionFind = (emptyEquivalence (0, length nodes-1)) 
          unionFind = (create (0, length nodes-1))           
          nodesMap = Map.fromList (zip nodes [0..])

process :: String -> (Int, [Int])
process fileContents = (bits, nodes)
                       where bits = extractBits $ processedFileContents !! 0
                             nodes = Set.toList . Set.fromList . map (toDecimal . trimSpaces) . (drop 1) $ processedFileContents
                             processedFileContents = splitOn "\n" fileContents
                             trimSpaces = filter (not . isSpace)
                             toDecimal = foldr (\c s -> s * 2 + c) 0 . reverse . map digitToInt -- http://pleac.sourceforge.net/pleac_haskell/numbers.html
                             extractBits header = read $ (splitOn " " header) !! 1 

main = do     
    withFile "clustering2.txt" ReadMode (\handle -> do  
        contents <- hGetContents handle   
        -- let numberOfClusters = findMaxClusters contents 
        numberOfClusters <- findMaxClusters contents           
        (putStrLn . show) numberOfClusters)    