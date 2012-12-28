import System.IO
import Data.List.Split
import Data.Char
import Data.Bits
import Control.Monad
import UnionFind

import Data.Map
import Data.List
import Data.Maybe
    
file = "clustering2_medium.txt"

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

neighbours :: Int -> [Int] -> [Int]
neighbours me offsets = Prelude.map (xor me) offsets ++ 
                        Prelude.map (\pair -> xor me ((pair !! 0) .|. (pair !! 1))) (combinationsOf 2 offsets) ++
                        [me]

process :: String -> (Int, [Int])
process fileContents = (bits, nodes)
    where bits = extractBits $ processedFileContents !! 0
          nodes = Prelude.map (toDecimal . trimSpaces) . (drop 1) $ processedFileContents
          processedFileContents = splitOn "\n" fileContents

maxCluster :: Int -> [Int] -> Equivalence Int -> Map Int [Int] -> Int
maxCluster bits nodes unionFind nodesMap = 
    numberOfComponents $ Data.List.foldl (\uf (x,y) -> equate x y uf) unionFind (foo nodes nodesMap)

-- numberOfComponents $ Data.List.foldl (\uf x -> equate 1 x uf) unionFind nodes

-- neighbours for one node
foo nodes nodesMap = 
    join $ Prelude.map (\(nodeIndex, node) -> Prelude.foldl (\acc node -> acc ++ [(nodeIndex, node)]) [] $ findNeighbours node) (zip [0..] nodes)
    where findNeighbours node = findNeighbouringNodes nodesMap (neighbours node (offsets (length nodes - 1)))  

-- Prelude.foldl (\acc node -> acc ++ [(0, node)]) [] $ findNeighbouringNodes theMap (neighbours 14734287 (offsets 23))


findNeighbouringNodes :: Map Int [Int] -> [Int] -> [Int]
findNeighbouringNodes nodesMap = 
    (join . Prelude.map fromJust . Prelude.filter isJust . Prelude.map (\neighbour -> Data.Map.lookup neighbour nodesMap))
          
toMap :: [Int] -> Map Int [Int]
toMap nodes = Data.Map.fromList $ Prelude.map asMapEntry $ (groupIgnoringIndex . sortIgnoringIndex) nodesWithIndexes
              where nodesWithIndexes = (zip [0..] nodes)
              
groupIgnoringIndex = groupBy (\(_,x) (_,y) -> x == y)   
sortIgnoringIndex = sortBy (\(_,x) (_,y) -> x `compare` y)
         
asMapEntry :: [(Int, Int)] -> (Int, [Int])
asMapEntry nodesWithIndexes = ((snd . head) nodesWithIndexes, Prelude.foldl (\acc (x,_) -> acc ++ [x]) [] nodesWithIndexes)
          
-- findMaxClusters :: String -> Int
findMaxClusters fileContents = 
    -- foo nodes nodesMap
    maxCluster bits nodes unionFind nodesMap
    where (bits,nodes) = process fileContents
          unionFind = emptyEquivalence (0, length nodes-1)
          nodesMap = toMap nodes

main = do     
    withFile file ReadMode (\handle -> do  
        contents <- hGetContents handle     
        (putStr . show . findMaxClusters) contents)
        
-- rel = equateAll [1,3,5,7,9] . equate 5 6 . equate 2 4 $ emptyEquivalence (1,10)