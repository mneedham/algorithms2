import System.IO
import Data.List.Split
import Debug.Trace
import qualified Data.Map as Map
import Data.Array as Array
import Data.Maybe
import System.IO.Unsafe
import Data.IORef
import System.Environment

import qualified Data.HashTable.IO as H

type HashTable k v = H.BasicHashTable k v

foo :: IO (HashTable Int Int)
foo = do
    ht <- H.new
    H.insert ht 1 1
    return ht
    
 
ref :: a -> IORef a
ref x = unsafePerformIO (newIORef x)    
             
                 
data Cache i = Cache {
    cachedItems :: IORef (Map.Map (Int, Int) Int)
}
                
memoize :: (Int -> Int -> Int) -> Int -> Int -> Int                  
memoize fn numberOfItems weight = unsafePerformIO $ do 
    let cache = ref (Map.empty :: Map.Map (Int, Int) Int)
    items <- readIORef cache
    if Map.lookup (numberOfItems, weight) items == Nothing then do
        let result = fn numberOfItems weight
        writeIORef cache $  Map.insert (numberOfItems, weight) result items
        return result
    else
        return (fromJust $ Map.lookup (numberOfItems, weight) items)
        
knapsackCached :: [[Int]] -> Int -> Int -> Int
knapsackCached rows weight numberOfItems = 
    inner (numberOfItems-1) weight
    where inner = memoize (\i w -> if i < 0 || w == 0 then 0
                                   else
                                     let best = inner (i-1) w 
                                         (vi:wi:_) = rows !! i in 
                                     if wi > w then best
                                     else maximum [best, vi + inner (i-1) (w-wi)])
        
process :: String -> (Int, Int, [[Int]])
process fileContents = (knapsackSize, numberOfItems, rows)
                       where (knapsackSize:numberOfItems:_) = extractHeader $ processedFileContents !! 0
                             rows =  map (map read) $ map (splitOn " ") $ drop 1 processedFileContents
                             processedFileContents = splitOn "\n" fileContents
                             extractHeader header = map read $ (splitOn " " header)

main = do 
    args <- getArgs
    contents <- readFile (args !! 0)
    let (knapsackSize, numberOfItems, rows) = process contents        
    putStrLn $ show $ knapsackCached rows knapsackSize numberOfItems