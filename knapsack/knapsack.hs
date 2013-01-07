import System.IO
import Data.List.Split
import Debug.Trace
import qualified Data.Map as Map
import Data.Array
import Data.Maybe

knapsackCached :: [[Int]] -> Int -> Int -> Array Int (Map.Map Int Int) -> Array Int (Map.Map Int Int)
knapsackCached rows knapsackSize index cache = 
    trace (show "top: " ++ show cache) $
    if index == 0 || knapsackSize == 0 
        then cache
    else
         let (value:weight:_) = rows !! index in
         if weight > knapsackSize && Map.lookup knapsackSize (cache ! (index-1)) == Nothing
             then                 
                 let newCache = knapsackCached rows knapsackSize (index-1) cache
                     newValue = fromJust $ Map.lookup (knapsackSize) (newCache ! (index-1))
                     updatedCache = newCache // [(index-1, Map.insert knapsackSize newValue (newCache ! (index-1)))] in
                 trace (show "updatedcache" ++ show newCache) $ updatedCache
         else
             if Map.lookup knapsackSize (cache ! (index-1)) == Nothing
                 then 
                     let newCache1 = knapsackCached rows knapsackSize (index-1) cache
                         newCache2 = knapsackCached rows (knapsackSize-weight) (index-1) cache
                         newValue1 = fromJust $ Map.lookup (knapsackSize) (newCache1 ! (index-1))
                         newValue2 = value + (fromJust $ Map.lookup (knapsackSize-weight) (newCache2 ! (index-1)))
                         updatedCache = if newValue1 > newValue2 
                                        then newCache1 // [((index-1), Map.insert knapsackSize newValue1 (newCache1 ! (index-1)))] 
                                        else newCache2 // [((index-1), Map.insert knapsackSize newValue2 (newCache2 ! (index-1)))] in
                     trace (show "updatedcache" ++ show updatedCache) $ updatedCache
             else
                 trace (show "no cache update: " ++ show cache) $
                 -- fromJust $ Map.lookup knapsackSize (cache ! (index - 1))
                 cache
        
process :: String -> (Int, Int, [[Int]])
process fileContents = (knapsackSize, numberOfItems, rows)
                       where (knapsackSize:numberOfItems:_) = extractHeader $ processedFileContents !! 0
                             rows =  map (map read) $ map (splitOn " ") $ drop 1 processedFileContents
                             processedFileContents = splitOn "\n" fileContents
                             extractHeader header = map read $ (splitOn " " header)

main = do 
    contents <- readFile "knapsack_small.txt"
    let (knapsackSize, numberOfItems, rows) = process contents
        cache = array (0, knapsackSize) [(x,Map.empty) | x<-[0..knapsackSize]]
        result  = knapsackCached rows knapsackSize (numberOfItems-1) cache
    putStrLn $ show $ result