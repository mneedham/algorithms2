import System.IO
import Data.List.Split
import Debug.Trace
import qualified Data.Map as Map
import Data.Array
import Data.Maybe

knapsackCached :: [[Int]] -> Int -> Int -> Array Int (Map.Map Int Int) -> Int
knapsackCached rows knapsackSize index cache = 
    trace (show cache) $
    -- trace ("ohhhh robin van persie " ++ show knapsackSize ++ " " ++ (show index)) $
    if index == 0 || knapsackSize == 0 
        then 0
    else
         let (value:weight:_) = rows !! index in
         if weight > knapsackSize && Map.lookup knapsackSize (cache ! (index-1)) == Nothing
             then
                 let knapsackSizeValue = knapsackCached rows knapsackSize (index-1) cache 
                     updatedCache = cache // [(index-1, Map.insert knapsackSize knapsackSizeValue (cache ! (index-1)))] in
                 fromJust $ Map.lookup knapsackSize (updatedCache ! (index-1))
         else
             if Map.lookup knapsackSize (cache ! (index-1)) == Nothing
                 then 
                     let knapsackSizeValue = maximum [knapsackCached rows knapsackSize (index-1) cache, 
                                                      value + knapsackCached rows (knapsackSize-weight) (index-1) cache]
                         updatedCache = cache // [(index-1, Map.insert knapsackSize knapsackSizeValue (cache ! (index-1)))] in
                     fromJust $ Map.lookup knapsackSize (updatedCache ! (index - 1))
             else
                 fromJust $ Map.lookup knapsackSize (cache ! (index - 1))
        
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
    putStrLn $ show $ knapsackCached rows knapsackSize (numberOfItems-1) cache