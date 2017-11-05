{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# OPTIONS_GHC -fshow-hole-constraints -Wall #-}
-- {-# OPTIONS_GHC -ddump-simpl -dsuppress-all #-}
{-# OPTIONS_GHC -O -fplugin GHC.Proof.Plugin #-}
{-# OPTIONS_GHC -funfolding-creation-threshold=5000 -funfolding-use-threshold=5000 #-}
module Main where

import Data.Monoid (Sum(..), Product(..), (<>))
import Generics.SOP
import Generics.SOP.NS
import GHC.Proof

import Proofs.Metadata
import Proofs.Types

---------------------------------------------------------------------
-- Simple properties

proof_caseSelf_T2 :: Proof
proof_caseSelf_T2 =
  (\ x -> case x of T2 a b -> T2 a b)
  ===
  (\ x -> x)

proof_caseSelf_Nil :: Proof
proof_caseSelf_Nil =
  (\ x -> case (x :: NP I '[]) of Nil -> Nil)
  ===
  (\ x -> x)

{-
-- fails
proof_caseSelf_ConsNil :: Proof
proof_caseSelf_ConsNil =
  (\ x -> case (x :: NP I '[Int]) of y :* Nil -> y :* Nil)
  ===
  (\ x -> x)
-}

---------------------------------------------------------------------
-- Roundtrips, from, to

proof_roundtrip_T2 :: Proof
proof_roundtrip_T2 =
  to . from
  ===
  idT2

proof_roundtrip_T2' :: Proof
proof_roundtrip_T2' =
  to . from
  ===
  idT2'

proof_roundtrip_Bool :: Proof
proof_roundtrip_Bool =
  to . from
  ===
  ((\ x -> x) :: Bool -> Bool)

{-
-- fails for unknown reasons (optimised correctly in GHC)
proof_roundtrip_Ordering :: Proof
proof_roundtrip_Ordering =
  to . from
  ===
  ((\ x -> x) :: Ordering -> Ordering)
-}

proof_roundtrip_E1 :: Proof
proof_roundtrip_E1 =
  to . from
  ===
  ((\ x -> x) :: E1 -> E1)

proof_roundtrip_E1' :: Proof
proof_roundtrip_E1' =
  to . from
  ===
  ((\ x -> x) :: E1' -> E1')

proof_roundtrip_E2 :: Proof
proof_roundtrip_E2 =
  to . from
  ===
  ((\ x -> x) :: E2 -> E2)

proof_roundtrip_E2' :: Proof
proof_roundtrip_E2' =
  to . from
  ===
  ((\ x -> x) :: E2' -> E2')

proof_roundtrip_E3 :: Proof
proof_roundtrip_E3 =
  to . from
  ===
  ((\ x -> x) :: E3 -> E3)

{-
-- fails for unknown reasons (optimises correctly in GHC)
proof_roundtrip_E3' :: Proof
proof_roundtrip_E3' =
  to . from
  ===
  ((\ x -> x) :: E3' -> E3')
-}

proof_doubleRoundtrip_T2 :: Proof
proof_doubleRoundtrip_T2 =
  roundt . roundt
  ===
  idT2
  where
    roundt :: T2 a b -> T2 a b
    roundt = to . from
    {-# INLINE roundt #-}

proof_doubleRoundtrip_T2' :: Proof
proof_doubleRoundtrip_T2' =
  roundt . roundt
  ===
  idT2'
  where
    roundt :: T2' a b -> T2' a b
    roundt = to . from
    {-# INLINE roundt #-}

proof_productRoundtrip_T2 :: Proof
proof_productRoundtrip_T2 =
  productTo . productFrom'
  ===
  idT2
  where
    productFrom' :: T2 a b -> NP I '[a, b]
    productFrom' = productFrom
    {-# INLINE productFrom' #-}

proof_productRoundtrip_T2' :: Proof
proof_productRoundtrip_T2' =
  productTo . productFrom'
  ===
  idT2'
  where
    productFrom' :: T2' a b -> NP I '[a, b]
    productFrom' = productFrom
    {-# INLINE productFrom' #-}

---------------------------------------------------------------------
-- cpure

gmempty :: (IsProductType a xs, All Monoid xs) => a
gmempty =
  productTo (hcpure (Proxy :: Proxy Monoid) (I mempty))
{-# INLINE gmempty #-}

mempty_T2 :: (Monoid a, Monoid b) => T2 a b
mempty_T2 =
  T2 mempty mempty

mempty_T2' :: (Monoid a, Monoid b) => T2' a b
mempty_T2' =
  T2' mempty mempty

mempty_T3 :: (Monoid a, Monoid b, Monoid c) => T3 a b c
mempty_T3 =
  T3 mempty mempty mempty

mempty_T3' :: (Monoid a, Monoid b, Monoid c) => T3' a b c
mempty_T3' =
  T3' mempty mempty mempty

proof_mempty_T2 :: Proof
proof_mempty_T2 =
  (Wrap2 gmempty :: Wrap2 Monoid T2)
  ===
  Wrap2 mempty_T2

proof_mempty_T2' :: Proof
proof_mempty_T2' =
  (Wrap2 gmempty :: Wrap2 Monoid T2')
  ===
  Wrap2 mempty_T2'

proof_mempty_T3 :: Proof
proof_mempty_T3 =
  (Wrap3 gmempty :: Wrap3 Monoid T3)
  ===
  Wrap3 mempty_T3

proof_mempty_T3' :: Proof
proof_mempty_T3' =
  (Wrap3 gmempty :: Wrap3 Monoid T3')
  ===
  Wrap3 mempty_T3'

{-
-- fails for somewhat mysterious reasons
proof_mempty_U10 :: Proof
proof_mempty_U10 =
  (Wrap1 gmempty :: Wrap1 Monoid U10)
  ===
  Wrap1 (U10
    mempty
    mempty
    mempty
    mempty
    mempty
    mempty
    mempty
    mempty
    mempty
    mempty)
-}

proof_mempty_U10' :: Proof
proof_mempty_U10' =
  (Wrap1 gmempty :: Wrap1 Monoid U10')
  ===
  Wrap1 (U10'
    mempty
    mempty
    mempty
    mempty
    mempty
    mempty
    mempty
    mempty
    mempty
    mempty)

proof_concreteMempty_Triple :: Proof
proof_concreteMempty_Triple =
  gmempty
  ===
  ((Sum 0, Product 1, []) :: (Sum Int, Product Int, [Bool]))

proof_concreteMempty_T3 :: Proof
proof_concreteMempty_T3 =
  gmempty
  ===
  (T3 (Sum 0) (Product 1) [] :: T3 (Sum Int) (Product Int) [Bool])

proof_concreteMempty_T3' :: Proof
proof_concreteMempty_T3' =
  gmempty
  ===
  (T3' (Sum 0) (Product 1) [] :: T3' (Sum Int) (Product Int) [Bool])

---------------------------------------------------------------------
-- cmap

gshow :: (Generic a, All2 Show (Code a)) => a -> String
gshow =
  concat . hcollapse . hcmap (Proxy :: Proxy Show) (mapIK show) . from
{-# INLINE gshow #-}

gproductShow :: (IsProductType a xs, All Show xs) => a -> String
gproductShow =
  concat . hcollapse . hcmap (Proxy :: Proxy Show) (mapIK show) . productFrom
{-# INLINE gproductShow #-}

{-
-- fails, due to GGP-conversion for single-constructor single-value datatype being lazy
proof_show_T1 :: Proof
proof_show_T1 =
  Wrap1' gshow
  ===
  (Wrap1' (\ (T1 x) -> show x) :: Wrap1' Show T1 String)
-}

proof_show_T1' :: Proof
proof_show_T1' =
  Wrap1' gshow
  ===
  (Wrap1' (\ (T1' x) -> show x) :: Wrap1' Show T1' String)

{-
-- fails, due to GGP-conversion for single-constructor single-value datatype being lazy
proof_productShow_T1 :: Proof
proof_productShow_T1 =
  Wrap1' gproductShow
  ===
  (Wrap1' (\ (T1 x) -> show x) :: Wrap1' Show T1 String)
-}

proof_productShow_T1' :: Proof
proof_productShow_T1' =
  Wrap1' gproductShow
  ===
  (Wrap1' (\ (T1' x) -> show x) :: Wrap1' Show T1' String)

proof_show_T2 :: Proof
proof_show_T2 =
  Wrap2' gshow
  ===
  (Wrap2' (\ (T2 x y) -> show x ++ show y) :: Wrap2' Show T2 String)

proof_show_T2' :: Proof
proof_show_T2' =
  Wrap2' gshow
  ===
  (Wrap2' (\ (T2' x y) -> show x ++ show y) :: Wrap2' Show T2' String)

proof_show_U10 :: Proof
proof_show_U10 =
  Wrap1' gshow
  ===
  (Wrap1' (\ (U10 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10) ->
       show a1
    ++ show a2
    ++ show a3
    ++ show a4
    ++ show a5
    ++ show a6
    ++ show a7
    ++ show a8
    ++ show a9
    ++ show a10) :: Wrap1' Show U10 String)

proof_show_U10' :: Proof
proof_show_U10' =
  Wrap1' gshow
  ===
  (Wrap1' (\ (U10' a1 a2 a3 a4 a5 a6 a7 a8 a9 a10) ->
       show a1
    ++ show a2
    ++ show a3
    ++ show a4
    ++ show a5
    ++ show a6
    ++ show a7
    ++ show a8
    ++ show a9
    ++ show a10) :: Wrap1' Show U10' String)

proof_show_E1 :: Proof
proof_show_E1 =
  gshow
  ===
  ((\ E1_0 -> "") :: E1 -> String)

proof_show_E1' :: Proof
proof_show_E1' =
  gshow
  ===
  ((\ E1'_0 -> "") :: E1' -> String)

proof_show_E2 :: Proof
proof_show_E2 =
  gshow
  ===
  ((\ !_ -> "") :: E2 -> String)

proof_show_E2' :: Proof
proof_show_E2' =
  gshow
  ===
  ((\ !_ -> "") :: E2' -> String)

proof_show_E3 :: Proof
proof_show_E3 =
  gshow
  ===
  ((\ !_ -> "") :: E3 -> String)

proof_show_E3' :: Proof
proof_show_E3' =
  gshow
  ===
  ((\ !_ -> "") :: E3' -> String)

proof_productShow_T2 :: Proof
proof_productShow_T2 =
  Wrap2' gproductShow
  ===
  (Wrap2' (\ (T2 x y) -> show x ++ show y) :: Wrap2' Show T2 String)

proof_productShow_T2' :: Proof
proof_productShow_T2' =
  Wrap2' gproductShow
  ===
  (Wrap2' (\ (T2' x y) -> show x ++ show y) :: Wrap2' Show T2' String)

proof_productShow_T3 :: Proof
proof_productShow_T3 =
  Wrap3' gproductShow
  ===
  (Wrap3' (\ (T3 x y z) -> show x ++ show y ++ show z) :: Wrap3' Show T3 String)

proof_productShow_T3' :: Proof
proof_productShow_T3' =
  Wrap3' gproductShow
  ===
  (Wrap3' (\ (T3' x y z) -> show x ++ show y ++ show z) :: Wrap3' Show T3' String)

proof_productShow_U10 :: Proof
proof_productShow_U10 =
  Wrap1' gproductShow
  ===
  (Wrap1' (\ (U10 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10) ->
       show a1
    ++ show a2
    ++ show a3
    ++ show a4
    ++ show a5
    ++ show a6
    ++ show a7
    ++ show a8
    ++ show a9
    ++ show a10) :: Wrap1' Show U10 String)

proof_productShow_U10' :: Proof
proof_productShow_U10' =
  Wrap1' gproductShow
  ===
  (Wrap1' (\ (U10' a1 a2 a3 a4 a5 a6 a7 a8 a9 a10) ->
       show a1
    ++ show a2
    ++ show a3
    ++ show a4
    ++ show a5
    ++ show a6
    ++ show a7
    ++ show a8
    ++ show a9
    ++ show a10) :: Wrap1' Show U10' String)

---------------------------------------------------------------------
-- czipWith

gmappend :: (IsProductType a xs, All Monoid xs) => a -> a -> a
gmappend =
  \ x y -> productTo (hczipWith (Proxy :: Proxy Monoid) (mapIII mappend)
    (productFrom x) (productFrom y))
{-# INLINE gmappend #-}

{-
-- fails, due to GGP-conversion for single-constructor single-value datatype being lazy
proof_mappend_T1 :: Proof
proof_mappend_T1 =
  Wrap1'' gmappend
  ===
  (Wrap1'' (\ (T1 x1) (T1 x2) -> T1 (x1 <> x2)) :: Wrap1'' Monoid T1)
-}

proof_mappend_T1' :: Proof
proof_mappend_T1' =
  Wrap1'' gmappend
  ===
  (Wrap1'' (\ (T1' x1) (T1' x2) -> T1' (x1 <> x2)) :: Wrap1'' Monoid T1')

proof_mappend_T2 :: Proof
proof_mappend_T2 =
  Wrap2'' gmappend
  ===
  (Wrap2'' (\ (T2 x1 y1) (T2 x2 y2) -> T2 (x1 <> x2) (y1 <> y2)) :: Wrap2'' Monoid T2)

proof_mappend_T2' :: Proof
proof_mappend_T2' =
  Wrap2'' gmappend
  ===
  (Wrap2'' (\ (T2' x1 y1) (T2' x2 y2) -> T2' (x1 <> x2) (y1 <> y2)) :: Wrap2'' Monoid T2')

proof_mappend_T3 :: Proof
proof_mappend_T3 =
  Wrap3'' gmappend
  ===
  (Wrap3'' (\ (T3 x1 y1 z1) (T3 x2 y2 z2) -> T3 (x1 <> x2) (y1 <> y2) (z1 <> z2)) :: Wrap3'' Monoid T3)

proof_mappend_T3' :: Proof
proof_mappend_T3' =
  Wrap3'' gmappend
  ===
  (Wrap3'' (\ (T3' x1 y1 z1) (T3' x2 y2 z2) -> T3' (x1 <> x2) (y1 <> y2) (z1 <> z2)) :: Wrap3'' Monoid T3')

proof_mappend_U10 :: Proof
proof_mappend_U10 =
  Wrap1'' gmappend
  ===
  (Wrap1'' (\ (U10 a0 a1 a2 a3 a4 a5 a6 a7 a8 a9) (U10 b0 b1 b2 b3 b4 b5 b6 b7 b8 b9) ->
    U10
      (a0 <> b0)
      (a1 <> b1)
      (a2 <> b2)
      (a3 <> b3)
      (a4 <> b4)
      (a5 <> b5)
      (a6 <> b6)
      (a7 <> b7)
      (a8 <> b8)
      (a9 <> b9)) :: Wrap1'' Monoid U10)

proof_mappend_U10' :: Proof
proof_mappend_U10' =
  Wrap1'' gmappend
  ===
  (Wrap1'' (\ (U10' a0 a1 a2 a3 a4 a5 a6 a7 a8 a9) (U10' b0 b1 b2 b3 b4 b5 b6 b7 b8 b9) ->
    U10'
      (a0 <> b0)
      (a1 <> b1)
      (a2 <> b2)
      (a3 <> b3)
      (a4 <> b4)
      (a5 <> b5)
      (a6 <> b6)
      (a7 <> b7)
      (a8 <> b8)
      (a9 <> b9)) :: Wrap1'' Monoid U10')

proof_concreteMappend_Triple :: Proof
proof_concreteMappend_Triple =
  gmappend
  ===
  (\ (Sum x1, Product x2, x3) (Sum y1, Product y2, y3) ->
    (Sum (x1 + y1 :: Int), Product (x2 * y2 :: Int), x3 ++ y3))

proof_concreteMappend_T3 :: Proof
proof_concreteMappend_T3 =
  gmappend
  ===
  (\ (T3 (Sum x1) (Product x2) x3) (T3 (Sum y1) (Product y2) y3) ->
    T3 (Sum (x1 + y1 :: Int)) (Product (x2 * y2 :: Int)) (x3 ++ y3))

---------------------------------------------------------------------
-- Metadata

proof_datatypeNameOf_T1 :: Proof
proof_datatypeNameOf_T1 =
  datatypeNameOf (Proxy :: Proxy (T1 ()))
  ===
  "T1"

proof_datatypeNameOf_T1' :: Proof
proof_datatypeNameOf_T1' =
  datatypeNameOf (Proxy :: Proxy (T1' ()))
  ===
  "T1'"

proof_datatypeNameOf_I10 :: Proof
proof_datatypeNameOf_I10 =
  datatypeNameOf (Proxy :: Proxy I10)
  ===
  "I10"

proof_datatypeNameOf_I10' :: Proof
proof_datatypeNameOf_I10' =
  datatypeNameOf (Proxy :: Proxy I10')
  ===
  "I10'"

proof_constructorNames_Bool :: Proof
proof_constructorNames_Bool =
  constructorNames (Proxy :: Proxy Bool)
  ===
  ["False", "True"]

proof_constructorNames_Ordering :: Proof
proof_constructorNames_Ordering =
  constructorNames (Proxy :: Proxy Ordering)
  ===
  ["LT", "EQ", "GT"]

proof_constructorNames_Maybe :: Proof
proof_constructorNames_Maybe =
  constructorNames (Proxy :: Proxy (Maybe Int))
  ===
  ["Nothing", "Just"]

proof_constructorNames_I10 :: Proof
proof_constructorNames_I10 =
  constructorNames (Proxy :: Proxy I10)
  ===
  ["I10"]

proof_constructorNames_I10' :: Proof
proof_constructorNames_I10' =
  constructorNames (Proxy :: Proxy I10')
  ===
  ["I10'"]

proof_theConstructor_True :: Proof
proof_theConstructor_True =
  theConstructor True
  ===
  "True"

proof_theConstructor_Bool :: Proof
proof_theConstructor_Bool =
  (\ x -> theConstructor x)
  ===
  (\ x -> case x of False -> "False"; True -> "True")

proof_theConstructor_Ordering :: Proof
proof_theConstructor_Ordering =
  (\ x -> theConstructor x)
  ===
  (\ x -> case x of LT -> "LT"; EQ -> "EQ"; GT -> "GT")

proof_theConstructor_Maybe :: Proof
proof_theConstructor_Maybe =
  (\ x -> theConstructor x)
  ===
  (\ x -> case x of Nothing -> "Nothing"; Just _ -> "Just")

-- Should this be strict?
proof_theConstructor_I10 :: Proof
proof_theConstructor_I10 =
  (\ x -> theConstructor (x :: I10))
  ===
  (\ _ -> "I10")

{-
-- This fails due to a strange combination of casts not being eliminated
proof_theConstructor_I10' :: Proof
proof_theConstructor_I10' =
  (\ x -> theConstructor (x :: I10'))
  ===
  (\ x -> case x of I10' _ _ _ _ _ _ _ _ _ _ -> "I10'")
-}

---------------------------------------------------------------------
-- injections

proof_injections_Nil :: Proof
proof_injections_Nil =
  (injections :: NP (Injection I '[]) '[])
  ===
  Nil

proof_injections_ConsNil :: Proof
proof_injections_ConsNil =
  (injections :: NP (Injection I '[Int]) '[Int])
  ===
  fn (\ x -> K (Z x)) :* Nil

proof_injections_ConsConsNil :: Proof
proof_injections_ConsConsNil =
  (injections :: NP (Injection I '[Int, Bool]) '[Int, Bool])
  ===
  fn (\ x -> K (Z x)) :* fn (\ x -> K (S (Z x))) :* Nil

---------------------------------------------------------------------
-- projections

proof_projections_Nil :: Proof
proof_projections_Nil =
  (projections :: NP (Projection I '[]) '[])
  ===
  Nil

proof_projections_ConsNil :: Proof
proof_projections_ConsNil =
  (projections :: NP (Projection I '[Int]) '[Int])
  ===
  fn (\ (K (x :* _)) -> x) :* Nil

{-
-- fails for unclear reasons
proof_projections_ConsConsNil :: Proof
proof_projections_ConsConsNil =
  (projections :: NP (Projection I '[Int, Bool]) '[Int, Bool])
  ===
  fn (\ (K (x :* _)) -> x) :* fn (\ (K (_ :* x :* _)) -> x) :* Nil
-}

---------------------------------------------------------------------
-- apInjs

genum :: IsEnumType a => [a]
genum =
  hcollapse genum'
{-# INLINE genum #-}

genum' :: IsEnumType a => NP (K a) (Code a)
genum' =
  hmap (mapKK to) (apInjs'_POP (POP (hcpure (Proxy :: Proxy ((~) '[])) Nil)))
{-# INLINE genum' #-}

{-
-- fails for unknown reasons (optimises correctly in GHC)
proof_enum'_Bool :: Proof
proof_enum'_Bool =
  genum'
  ===
  K False :* K True :* Nil
-}

proof_enum'_E1 :: Proof
proof_enum'_E1 =
  genum'
  ===
  K E1_0 :* Nil

proof_enum'_E1' :: Proof
proof_enum'_E1' =
  genum'
  ===
  K E1'_0 :* Nil

proof_enum_E1 :: Proof
proof_enum_E1 =
  genum
  ===
  [E1_0]

proof_enum_E1' :: Proof
proof_enum_E1' =
  genum
  ===
  [E1'_0]

proof_enum'_E2 :: Proof
proof_enum'_E2 =
  genum'
  ===
  K E2_0 :* K E2_1 :* Nil

{-
-- fails for unknown reasons
proof_enum'_E2' :: Proof
proof_enum'_E2' =
  genum'
  ===
  K E2'_0 :* K E2'_1 :* Nil
-}

proof_enum'_E3 :: Proof
proof_enum'_E3 =
  genum'
  ===
  K E3_0 :* K E3_1 :* K E3_2 :* Nil

proof_enum_E3 :: Proof
proof_enum_E3 =
  genum
  ===
  [E3_0, E3_1, E3_2]

genum_E50' :: [E50']
genum_E50' = genum

proof_enum'_E10 :: Proof
proof_enum'_E10 =
  genum'
  ===
  K E10_0 :* K E10_1 :* K E10_2 :* K E10_3 :* K E10_4 :* K E10_5 :* K E10_6 :* K E10_7 :* K E10_8 :* K E10_9 :* Nil

{-
-- fails for unknown reasons
proof_enum'_E10' :: Proof
proof_enum'_E10' =
  genum'
  ===
  K E10'_0 :* K E10'_1 :* K E10'_2 :* K E10'_3 :* K E10'_4 :* K E10'_5 :* K E10'_6 :* K E10'_7 :* K E10'_8 :* K E10'_9 :* Nil
-}

main :: IO ()
main = return ()

