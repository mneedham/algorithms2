{-|
    Code for manipulation of equivalence classes on index types.  An
    'Equivalence' is an equivalence relation.  The empty equivalence relation
    is constructed over a ranges of values using 'emptyEquivalence'.  Less
    discerning equivalence relations can be obtained with 'equate' and
    'equateAll'.  The relation can be tested with 'equiv' and 'equivalent'.

    An example follows:

    > import Data.Equivalence.Persistent
    >
    > rel = equateAll [1,3,5,7,9]
    >     . equate 5 6
    >     . equate 2 4
    >     $ emptyEquivalence (1,10)
    >
    > test1 = equiv rel 3 5 -- This is True
    > test2 = equiv rel 1 6 -- This is True
    > test3 = equiv rel 4 6 -- This is False
-}
module UnionFind (
    Equivalence,
    emptyEquivalence,
    equiv,
    equate,
    repr,
    numberOfComponents,
    components
    )
    where

import Control.Concurrent.MVar
import Control.Monad
import Data.Array.Diff
import Data.IORef
import Data.List
import Data.Maybe
import System.IO.Unsafe
import Data.Set

arrayFrom :: (IArray a e, Ix i) => (i,i) -> (i -> e) -> a i e
arrayFrom rng f = array rng [ (x, f x) | x <- range rng ]

{-
    Convenience method for building "transparent" references.  These must
    have the property that updating them makes no semantic change in their
    value; otherwise, references really need to be created in an IO block.
-}
ref :: a -> IORef a
ref x = unsafePerformIO (newIORef x)

{-|
    An 'Equivalence' is an equivalence relation on a range of values of some
    index type.
-}
data Equivalence i = Equivalence {
    ranks :: DiffArray i Int,
    parents :: IORef (DiffArray i i)
    }

{-|
    'emptyEquivalence' is an equivalence relation that equates two values
    only when they are equal to each other.  It is the most discerning such
    relation possible.
-}
emptyEquivalence :: Ix i => (i, i) -> Equivalence i
emptyEquivalence is = Equivalence (arrayFrom is (const 0))
                                  (ref (arrayFrom is id))
                                  
numberOfComponents :: Ix i => Equivalence i -> Int
numberOfComponents (Equivalence rs vps) = unsafePerformIO $ do
    ps <- readIORef vps
    return ((size . fromList . Data.Array.Diff.elems) ps)
    
components :: Ix i => Equivalence i -> [i]
components (Equivalence rs vps) = unsafePerformIO $ do
    ps <- readIORef vps
    return ((toList . fromList . Data.Array.Diff.elems) ps)
      

reprHelper :: Ix i => DiffArray i i -> i -> (Maybe (DiffArray i i), i)
reprHelper ps i
    | pi == i   = (Nothing, i)
    | otherwise = let (ps', r) = reprHelper ps pi
                  in  (Just (fromMaybe ps ps' // [(i,r)]), r)
  where pi = ps ! i

{-
    'repr' gives a canonical representative of the equivalence class
    containing @x@.  It is chosen arbitrarily, but is always the same for a
    given class and 'Equivalence' value.

    This is not exported, because clients that use this are doing something
    wrong.  Note that:

    * The representative chosen depends on the order in which the
      equivalence relation was built, and is not always the same for
      values that represent the same relation.

    * The representative is not particularly stable.  Uses of 'equate' are
      highly likely to change it.

    * If all you need is some representative of the equivalence class,
      you have to provide one as input to the function anyway, so you
      may as well use that.

    The only guarantee provided is that repr always returns the same value for
    the exact same 'Equivalence'.
-}
repr :: Ix i => Equivalence i -> i -> i
repr (Equivalence rs vps) i = unsafePerformIO $ do
    ps <- readIORef vps
    let (ps', r) = reprHelper ps (ps ! i)
    maybe (return ()) (writeIORef vps) ps'
    return r

{-|
    Determines if two values are equivalent under the given equivalence
    relation.
-}
equiv :: Ix i => Equivalence i -> i -> i -> Bool
equiv eq x y = repr eq x == repr eq y


{-|
    Construct the equivalence relation obtained by equating the given two
    values.  This combines equivalence classes.
-}
equate :: Ix i => i -> i -> Equivalence i -> Equivalence i
equate x y (Equivalence rs vps) = unsafePerformIO $ do
    ps <- readIORef vps
    let (ps',  px) = reprHelper ps                 x
        (ps'', py) = reprHelper (fromMaybe ps ps') y
    psFinal <- case ps' of
        Nothing -> do maybe (return ()) (writeIORef vps) ps''
                      return (fromMaybe ps ps'')
        Just t  -> do writeIORef vps (fromMaybe t ps'')
                      return (fromMaybe t ps'')
    return (go px py psFinal)
  where
    go px py ps
        | px == py  = Equivalence rs vps
        | rx > ry   = let ps' = ps // [(py, px)]
                      in Equivalence rs (ref ps')
        | rx < ry   = let ps' = ps // [(px, py)]
                      in Equivalence rs (ref ps')
        | otherwise = let ps' = ps // [(py, px)]
                          rs' = rs // [(px, (rx + 1))]
                      in Equivalence rs' (ref ps')
      where rx = rs ! px
            ry = rs ! py

