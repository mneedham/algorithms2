module UnboundedArray where
    
import Data.Array
import Data.IORef
import System.IO.Unsafe

type UnboundedArray a = Int -> a

-- | Create an unbounded array from an infinite list
--   Accessing element /n/ takes /O(n)/ time, but only /O(1)/ amortized time.
unboundedArray :: [a] -> UnboundedArray a
unboundedArray xs = unsafePerformIO . unsafePerformIO (unboundedArrayIO xs)

unboundedArrayIO :: [a] -> IO (Int -> IO a)
unboundedArrayIO xs = do
    theArray <- newIORef (listArray (0,0) xs)
    return $ \n -> do
        ar <- readIORef theArray
        let (0,size) = bounds ar
        if n <= size
          then return $ ar ! n
          else do let size' = max n (size * 3 `div` 2)
                  let ar' = listArray (0,size') xs
                  writeIORef theArray ar'
                  return $ ar' ! n