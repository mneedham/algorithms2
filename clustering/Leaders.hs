module Leaders (UnionSet, create, components, numberOfComponents, inSameComponent, union) where

import Control.Concurrent.MVar
import Control.Monad
import Data.Array.Diff as ArrayDiff
import Data.IORef
import qualified Data.List
import Data.Maybe
import System.IO.Unsafe
import qualified Data.Set as Set

arrayFrom :: (IArray a e, Ix i) => (i,i) -> (i -> e) -> a i e
arrayFrom rng f = array rng [ (x, f x) | x <- range rng ]

ref :: a -> IORef a
ref x = unsafePerformIO (newIORef x)

data UnionSet i = UnionSet { leaders :: IORef (DiffArray i i) }

create :: Ix i => (i, i) -> UnionSet i
create is = UnionSet (ref (arrayFrom is id))

extractComponents :: Ix i => DiffArray i i -> [i]    
extractComponents  = Set.toList . Set.fromList . ArrayDiff.elems

-- functions on arrays http://zvon.org/other/haskell/Outputarray/index.html
components :: Ix i => UnionSet i -> [i]
components (UnionSet leaders) = unsafePerformIO $ do
    l <- readIORef leaders
    return (extractComponents l)
    
indexes :: Ix i => UnionSet i -> [(i,i)]
indexes (UnionSet leaders) = unsafePerformIO $ do
    l <- readIORef leaders
    return (ArrayDiff.assocs l)    
    
numberOfComponents :: Ix i => UnionSet i -> Int
numberOfComponents (UnionSet leaders) = unsafePerformIO $ do
    l <- readIORef leaders
    return (length $ extractComponents l)    

inSameComponent :: Ix i => UnionSet i -> i -> i -> Bool
inSameComponent (UnionSet leaders) x y = unsafePerformIO $ do
    l <- readIORef leaders
    return (l ! x == l ! y)
    
union x y (UnionSet leaders)  = unsafePerformIO $ do
    ls <- readIORef leaders
    let leader1 = ls ! x 
        leader2 = ls ! y
        newLeaders = map (\(index, value) -> (index, leader2)) . filter (\(index, value) -> value == leader1) $ assocs ls        
    modifyIORef leaders (\l -> l // newLeaders)
    return $ UnionSet leaders
