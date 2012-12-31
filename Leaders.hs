module Leaders (
    UnionSet,
    create,
    components,
    numberOfComponents,
    inSameComponent,
    union
    )
    where

import Control.Concurrent.MVar
import Control.Monad
import Data.Array.Diff as ArrayDiff
import Data.IORef
import qualified Data.List
import Data.Maybe
import System.IO.Unsafe
import qualified Data.Set as Set
import Debug.Trace

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
    
numberOfComponents :: Ix i => UnionSet i -> Int
numberOfComponents (UnionSet leaders) = unsafePerformIO $ do
    l <- readIORef leaders
    return (length $ extractComponents l)    

inSameComponent :: Ix i => UnionSet i -> i -> i -> Bool
inSameComponent (UnionSet leaders) x y = unsafePerformIO $ do
    l <- readIORef leaders
    return (l ! x == l ! y)
    
-- union :: Ix i => UnionSet i -> i -> i -> UnionSet i
-- union :: (Num i, Ix i) => UnionSet i -> i -> i -> UnionSet i
union (UnionSet leaders) x y = unsafePerformIO $ do
    ls <- readIORef leaders
    let leader1 = ls ! x 
        leader2 = ls ! y
        -- newLeaders = map (\(index, value) -> if value == leader1 then (index, leader2) else (index, value)) (assocs ls)
        newLeaders = map (\(index, value) -> (index, leader2)) . filter (\(index, value) -> value == leader1) $ assocs ls
    -- modifyIORef leaders (\l -> l // newLeaders)
    writeIORef leaders (ls // newLeaders)    
    -- lAfter <- readIORef leaders
    -- trace ("Before:" ++ show lBefore ++ ", After:" ++ show lAfter) $ return (UnionSet leaders)
    return $ UnionSet leaders
    -- return (UnionSet (ref $ array (0, (length newLeaders - 1)) newLeaders))
    -- return (UnionSet (ref $ array (0, (length (assocs ls) - 1)) (ls // newLeaders)))
    
    -- return if id1 == id2
    -- leader_1, leader_2 = @leaders[id1], @leaders[id2]
    -- @leaders.map! {|i| (i == leader_1) ? leader_2 : i }
