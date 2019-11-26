------------------------------------------------------------------------
-- The Agda standard library
--
-- Some properties about subsets
------------------------------------------------------------------------

{-# OPTIONS --without-K --safe #-}

module Data.Fin.Subset.Properties where

import Algebra.Definitions as AlgebraicDefinitions
import Algebra.Structures as AlgebraicStructures
open import Algebra.Bundles
import Algebra.Properties.Lattice as L
import Algebra.Properties.DistributiveLattice as DL
import Algebra.Properties.BooleanAlgebra as BA
open import Data.Bool using (not)
open import Data.Bool.Properties
open import Data.Fin using (Fin; suc; zero)
open import Data.Fin.Subset
open import Data.Fin.Properties using (any?; decFinSubset)
open import Data.Nat.Base using (ℕ; zero; suc; z≤n; s≤s; _≤_)
open import Data.Nat.Properties using (≤-step)
open import Data.Product as Product using (∃; ∄; _×_; _,_)
open import Data.Sum as Sum using (_⊎_; inj₁; inj₂; [_,_]′)
open import Data.Vec
open import Data.Vec.Properties
open import Function.Base using (_∘_; const; id; case_of_)
open import Function.Equivalence using (_⇔_; equivalence)
open import Relation.Binary as B hiding (Decidable)
open import Relation.Binary.PropositionalEquality
  using (_≡_; refl; cong; cong₂; subst; sym; isEquivalence; inspect; [_])
open import Relation.Nullary using (Dec; yes; no)
import Relation.Nullary.Decidable as Dec
open import Relation.Nullary.Negation using (contradiction)
open import Relation.Nullary.Sum using (_⊎-dec_)
open import Relation.Unary using (Pred; Decidable; Satisfiable)

------------------------------------------------------------------------
-- Constructor mangling

drop-there : ∀ {s n x} {p : Subset n} → suc x ∈ s ∷ p → x ∈ p
drop-there (there x∈p) = x∈p

drop-∷-⊆ : ∀ {n s₁ s₂} {p₁ p₂ : Subset n} → s₁ ∷ p₁ ⊆ s₂ ∷ p₂ → p₁ ⊆ p₂
drop-∷-⊆ p₁s₁⊆p₂s₂ x∈p₁ = drop-there (p₁s₁⊆p₂s₂ (there x∈p₁))

module _ {n} {p q : Subset n} where

  out⊆ : ∀ {y} → p ⊆ q → outside ∷ p ⊆ y ∷ q
  out⊆ p⊆q (there ∈p) = there (p⊆q ∈p)

  out⊆-⇔ : ∀ {y} → p ⊆ q ⇔ outside ∷ p ⊆ y ∷ q
  out⊆-⇔ = equivalence out⊆ drop-∷-⊆

  in⊆in : p ⊆ q → inside ∷ p ⊆ inside ∷ q
  in⊆in p⊆q here = here
  in⊆in p⊆q (there ∈p) = there (p⊆q ∈p)

  in⊆in-⇔ : p ⊆ q ⇔ inside ∷ p ⊆ inside ∷ q
  in⊆in-⇔ = equivalence in⊆in drop-∷-⊆

------------------------------------------------------------------------
-- _∈_

infix 4 _∈?_
_∈?_ : ∀ {n} x (p : Subset n) → Dec (x ∈ p)
zero  ∈? inside  ∷ p = yes here
zero  ∈? outside ∷ p = no  λ()
suc n ∈? s       ∷ p = Dec.map′ there drop-there (n ∈? p)

------------------------------------------------------------------------
-- Empty

drop-∷-Empty : ∀ {n s} {p : Subset n} → Empty (s ∷ p) → Empty p
drop-∷-Empty ¬∃∈ (x , x∈p) = ¬∃∈ (suc x , there x∈p)

Empty-unique : ∀ {n} {p : Subset n} → Empty p → p ≡ ⊥
Empty-unique {_} {[]}          ¬∃∈ = refl
Empty-unique {_} {inside  ∷ p} ¬∃∈ = contradiction (zero , here) ¬∃∈
Empty-unique {_} {outside ∷ p} ¬∃∈ =
  cong (outside ∷_) (Empty-unique (drop-∷-Empty ¬∃∈))

nonempty? : ∀ {n} → Decidable (Nonempty {n})
nonempty? p = any? (_∈? p)

------------------------------------------------------------------------
-- ∣_∣

∣p∣≤n : ∀ {n} (p : Subset n) → ∣ p ∣ ≤ n
∣p∣≤n = count≤n (_≟ inside)

------------------------------------------------------------------------
-- ⊥

∉⊥ : ∀ {n} {x : Fin n} → x ∉ ⊥
∉⊥ (there p) = ∉⊥ p

⊥⊆ : ∀ {n} {p : Subset n} → ⊥ ⊆ p
⊥⊆ x∈⊥ = contradiction x∈⊥ ∉⊥

∣⊥∣≡0 : ∀ n → ∣ ⊥ {n = n} ∣ ≡ 0
∣⊥∣≡0 zero    = refl
∣⊥∣≡0 (suc n) = ∣⊥∣≡0 n

------------------------------------------------------------------------
-- ⊤

∈⊤ : ∀ {n} {x : Fin n} → x ∈ ⊤
∈⊤ {x = zero}  = here
∈⊤ {x = suc x} = there ∈⊤

⊆⊤ : ∀ {n} {p : Subset n} → p ⊆ ⊤
⊆⊤ = const ∈⊤

∣⊤∣≡n : ∀ n → ∣ ⊤ {n = n} ∣ ≡ n
∣⊤∣≡n zero    = refl
∣⊤∣≡n (suc n) = cong suc (∣⊤∣≡n n)

------------------------------------------------------------------------
-- ⁅_⁆

x∈⁅x⁆ : ∀ {n} (x : Fin n) → x ∈ ⁅ x ⁆
x∈⁅x⁆ zero    = here
x∈⁅x⁆ (suc x) = there (x∈⁅x⁆ x)

x∈⁅y⁆⇒x≡y : ∀ {n x} (y : Fin n) → x ∈ ⁅ y ⁆ → x ≡ y
x∈⁅y⁆⇒x≡y zero    here      = refl
x∈⁅y⁆⇒x≡y zero    (there p) = contradiction p ∉⊥
x∈⁅y⁆⇒x≡y (suc y) (there p) = cong suc (x∈⁅y⁆⇒x≡y y p)

x∈⁅y⁆⇔x≡y : ∀ {n} {x y : Fin n} → x ∈ ⁅ y ⁆ ⇔ x ≡ y
x∈⁅y⁆⇔x≡y {_} {x} {y} = equivalence
  (x∈⁅y⁆⇒x≡y y)
  (λ x≡y → subst (λ y → x ∈ ⁅ y ⁆) x≡y (x∈⁅x⁆ x))

∣⁅x⁆∣≡1 : ∀ {n} (i : Fin n) → ∣ ⁅ i ⁆ ∣ ≡ 1
∣⁅x⁆∣≡1 {suc n} zero    = cong suc (∣⊥∣≡0 n)
∣⁅x⁆∣≡1 {_}     (suc i) = ∣⁅x⁆∣≡1 i

------------------------------------------------------------------------
-- _⊆_

⊆-refl : ∀ {n} → Reflexive (_⊆_ {n})
⊆-refl = id

⊆-reflexive : ∀ {n} → _≡_ ⇒ (_⊆_ {n})
⊆-reflexive refl = ⊆-refl

⊆-trans : ∀ {n} → Transitive (_⊆_ {n})
⊆-trans p⊆q q⊆r x∈p = q⊆r (p⊆q x∈p)

⊆-antisym : ∀ {n} → Antisymmetric _≡_ (_⊆_ {n})
⊆-antisym {i = []}     {[]}     p⊆q q⊆p = refl
⊆-antisym {i = x ∷ xs} {y ∷ ys} p⊆q q⊆p with x | y
... | inside  | inside  = cong₂ _∷_ refl (⊆-antisym (drop-∷-⊆ p⊆q) (drop-∷-⊆ q⊆p))
... | inside  | outside = contradiction (p⊆q here) λ()
... | outside | inside  = contradiction (q⊆p here) λ()
... | outside | outside = cong₂ _∷_ refl (⊆-antisym (drop-∷-⊆ p⊆q) (drop-∷-⊆ q⊆p))

⊆-min : ∀ {n} → Minimum (_⊆_ {n}) ⊥
⊆-min (x ∷ xs) (there v∈⊥) = there (⊆-min xs v∈⊥)

⊆-max : ∀ {n} → Maximum (_⊆_ {n}) ⊤
⊆-max (inside ∷ xs) here         = here
⊆-max (x      ∷ xs) (there v∈xs) = there (⊆-max xs v∈xs)

infix 4 _⊆?_
_⊆?_ : ∀ {n} → B.Decidable (_⊆_ {n = n})
[]          ⊆? []          = yes id
outside ∷ p ⊆?       y ∷ q = Dec.map out⊆-⇔ (p ⊆? q)
inside  ∷ p ⊆? outside ∷ q = no (λ p⊆q → case (p⊆q here) of λ())
inside  ∷ p ⊆? inside  ∷ q = Dec.map in⊆in-⇔ (p ⊆? q)

module _ (n : ℕ) where

  ⊆-isPreorder : IsPreorder _≡_ (_⊆_ {n})
  ⊆-isPreorder = record
    { isEquivalence = isEquivalence
    ; reflexive     = ⊆-reflexive
    ; trans         = ⊆-trans
    }

  ⊆-preorder : Preorder _ _ _
  ⊆-preorder = record
    { isPreorder = ⊆-isPreorder
    }

  ⊆-isPartialOrder : IsPartialOrder _≡_ (_⊆_ {n})
  ⊆-isPartialOrder = record
    { isPreorder = ⊆-isPreorder
    ; antisym    = ⊆-antisym
    }

  ⊆-poset : Poset _ _ _
  ⊆-poset = record
    { isPartialOrder = ⊆-isPartialOrder
    }

p⊆q⇒∣p∣<∣q∣ : ∀ {n} {p q : Subset n} → p ⊆ q → ∣ p ∣ ≤ ∣ q ∣
p⊆q⇒∣p∣<∣q∣ {p = []}          {[]}          p⊆q = z≤n
p⊆q⇒∣p∣<∣q∣ {p = outside ∷ p} {outside ∷ q} p⊆q = p⊆q⇒∣p∣<∣q∣ (drop-∷-⊆ p⊆q)
p⊆q⇒∣p∣<∣q∣ {p = outside ∷ p} {inside  ∷ q} p⊆q = ≤-step (p⊆q⇒∣p∣<∣q∣ (drop-∷-⊆ p⊆q))
p⊆q⇒∣p∣<∣q∣ {p = inside  ∷ p} {outside ∷ q} p⊆q = contradiction (p⊆q here) λ()
p⊆q⇒∣p∣<∣q∣ {p = inside  ∷ p} {inside  ∷ q} p⊆q = s≤s (p⊆q⇒∣p∣<∣q∣ (drop-∷-⊆ p⊆q))

------------------------------------------------------------------------
-- ∁

x∈s⇒x∉∁s : ∀ {n} → {x : Fin n} → {s : Subset n} → x ∈ s → x ∉ ∁ s
x∈s⇒x∉∁s (there x∈s) (there x∈∁s) = x∈s⇒x∉∁s x∈s x∈∁s

x∈∁s⇒x∉s : ∀ {n} → {x : Fin n} → {s : Subset n} → x ∈ ∁ s → x ∉ s
x∈∁s⇒x∉s (there x∈∁s) (there x∈s) = x∈∁s⇒x∉s x∈∁s x∈s

x∉∁s⇒x∈s : ∀ {n} → {x : Fin n} → {s : Subset n} → x ∉ ∁ s → x ∈ s
x∉∁s⇒x∈s {x = zero}  {outside ∷ s} x∉∁s = contradiction here x∉∁s
x∉∁s⇒x∈s {x = zero}  {inside  ∷ s} x∉∁s = here
x∉∁s⇒x∈s {x = suc x} {_       ∷ s} x∉∁s = there (x∉∁s⇒x∈s (x∉∁s ∘ there))

x∉s⇒x∈∁s : ∀ {n} → {x : Fin n} → {s : Subset n} → x ∉ s → x ∈ ∁ s
x∉s⇒x∈∁s {x = zero}  {outside ∷ s} x∉s = here
x∉s⇒x∈∁s {x = zero}  {inside  ∷ s} x∉s = contradiction here x∉s
x∉s⇒x∈∁s {x = suc x} {_       ∷ s} x∉s = there (x∉s⇒x∈∁s (x∉s ∘ there))

------------------------------------------------------------------------
-- _∩_

module _ {n : ℕ} where

  open AlgebraicDefinitions {A = Subset n} _≡_

  ∩-assoc : Associative _∩_
  ∩-assoc = zipWith-assoc ∧-assoc

  ∩-comm : Commutative _∩_
  ∩-comm = zipWith-comm ∧-comm

  ∩-idem : Idempotent _∩_
  ∩-idem = zipWith-idem ∧-idem

  ∩-identityˡ : LeftIdentity ⊤ _∩_
  ∩-identityˡ = zipWith-identityˡ ∧-identityˡ

  ∩-identityʳ : RightIdentity ⊤ _∩_
  ∩-identityʳ = zipWith-identityʳ ∧-identityʳ

  ∩-identity : Identity ⊤ _∩_
  ∩-identity = ∩-identityˡ , ∩-identityʳ

  ∩-zeroˡ : LeftZero ⊥ _∩_
  ∩-zeroˡ = zipWith-zeroˡ ∧-zeroˡ

  ∩-zeroʳ : RightZero ⊥ _∩_
  ∩-zeroʳ = zipWith-zeroʳ ∧-zeroʳ

  ∩-zero : Zero ⊥ _∩_
  ∩-zero = ∩-zeroˡ , ∩-zeroʳ

  ∩-inverseˡ : LeftInverse ⊥ ∁ _∩_
  ∩-inverseˡ = zipWith-inverseˡ ∧-inverseˡ

  ∩-inverseʳ : RightInverse ⊥ ∁ _∩_
  ∩-inverseʳ = zipWith-inverseʳ ∧-inverseʳ

  ∩-inverse : Inverse ⊥ ∁ _∩_
  ∩-inverse = ∩-inverseˡ , ∩-inverseʳ

module _ (n : ℕ) where

  open AlgebraicStructures {A = Subset n} _≡_

  ∩-isMagma : IsMagma _∩_
  ∩-isMagma = record
    { isEquivalence = isEquivalence
    ; ∙-cong        = cong₂ _∩_
    }

  ∩-magma : Magma _ _
  ∩-magma = record
    { isMagma = ∩-isMagma
    }

  ∩-isSemigroup : IsSemigroup _∩_
  ∩-isSemigroup = record
    { isMagma = ∩-isMagma
    ; assoc   = ∩-assoc
    }

  ∩-semigroup : Semigroup _ _
  ∩-semigroup = record
    { isSemigroup = ∩-isSemigroup
    }

  ∩-isBand : IsBand _∩_
  ∩-isBand = record
    { isSemigroup = ∩-isSemigroup
    ; idem        = ∩-idem
    }

  ∩-band : Band _ _
  ∩-band = record
    { isBand = ∩-isBand
    }

  ∩-isSemilattice : IsSemilattice _∩_
  ∩-isSemilattice = record
    { isBand = ∩-isBand
    ; comm   = ∩-comm
    }

  ∩-semilattice : Semilattice _ _
  ∩-semilattice = record
    { isSemilattice = ∩-isSemilattice
    }

  ∩-isMonoid : IsMonoid _∩_ ⊤
  ∩-isMonoid = record
    { isSemigroup = ∩-isSemigroup
    ; identity    = ∩-identity
    }

  ∩-monoid : Monoid _ _
  ∩-monoid = record
    { isMonoid = ∩-isMonoid
    }

  ∩-isCommutativeMonoid : IsCommutativeMonoid _∩_ ⊤
  ∩-isCommutativeMonoid = record
    { isSemigroup = ∩-isSemigroup
    ; identityˡ   = ∩-identityˡ
    ; comm        = ∩-comm
    }

  ∩-commutativeMonoid : CommutativeMonoid _ _
  ∩-commutativeMonoid = record
    { isCommutativeMonoid = ∩-isCommutativeMonoid
    }

  ∩-isIdempotentCommutativeMonoid : IsIdempotentCommutativeMonoid _∩_ ⊤
  ∩-isIdempotentCommutativeMonoid = record
    { isCommutativeMonoid = ∩-isCommutativeMonoid
    ; idem                = ∩-idem
    }

  ∩-idempotentCommutativeMonoid : IdempotentCommutativeMonoid _ _
  ∩-idempotentCommutativeMonoid = record
    { isIdempotentCommutativeMonoid = ∩-isIdempotentCommutativeMonoid
    }

p∩q⊆p : ∀ {n} (p q : Subset n) → p ∩ q ⊆ p
p∩q⊆p []            []           x∈p∩q        = x∈p∩q
p∩q⊆p (inside  ∷ p) (inside ∷ q) here         = here
p∩q⊆p (inside  ∷ p) (_      ∷ q) (there ∈p∩q) = there (p∩q⊆p p q ∈p∩q)
p∩q⊆p (outside ∷ p) (_      ∷ q) (there ∈p∩q) = there (p∩q⊆p p q ∈p∩q)

p∩q⊆q : ∀ {n} (p q : Subset n) → p ∩ q ⊆ q
p∩q⊆q p q rewrite ∩-comm p q = p∩q⊆p q p

x∈p∩q⁺ : ∀ {n} {p q : Subset n} {x} → x ∈ p × x ∈ q → x ∈ p ∩ q
x∈p∩q⁺ (here      , here)      = here
x∈p∩q⁺ (there x∈p , there x∈q) = there (x∈p∩q⁺ (x∈p , x∈q))

x∈p∩q⁻ : ∀ {n} (p q : Subset n) {x} → x ∈ p ∩ q → x ∈ p × x ∈ q
x∈p∩q⁻ (inside ∷ p) (inside ∷ q) here          = here , here
x∈p∩q⁻ (s      ∷ p) (t      ∷ q) (there x∈p∩q) =
  Product.map there there (x∈p∩q⁻ p q x∈p∩q)

∩⇔× : ∀ {n} {p q : Subset n} {x} → x ∈ p ∩ q ⇔ (x ∈ p × x ∈ q)
∩⇔× = equivalence (x∈p∩q⁻ _ _) x∈p∩q⁺

------------------------------------------------------------------------
-- _∪_

module _ {n : ℕ} where

  open AlgebraicDefinitions {A = Subset n} _≡_

  ∪-assoc : Associative _∪_
  ∪-assoc = zipWith-assoc ∨-assoc

  ∪-comm : Commutative _∪_
  ∪-comm = zipWith-comm ∨-comm

  ∪-idem : Idempotent _∪_
  ∪-idem = zipWith-idem ∨-idem

  ∪-identityˡ : LeftIdentity ⊥ _∪_
  ∪-identityˡ = zipWith-identityˡ ∨-identityˡ

  ∪-identityʳ : RightIdentity ⊥ _∪_
  ∪-identityʳ = zipWith-identityʳ ∨-identityʳ

  ∪-identity : Identity ⊥ _∪_
  ∪-identity = ∪-identityˡ , ∪-identityʳ

  ∪-zeroˡ : LeftZero ⊤ _∪_
  ∪-zeroˡ = zipWith-zeroˡ ∨-zeroˡ

  ∪-zeroʳ : RightZero ⊤ _∪_
  ∪-zeroʳ = zipWith-zeroʳ ∨-zeroʳ

  ∪-zero : Zero ⊤ _∪_
  ∪-zero = ∪-zeroˡ , ∪-zeroʳ

  ∪-inverseˡ : LeftInverse ⊤ ∁ _∪_
  ∪-inverseˡ = zipWith-inverseˡ ∨-inverseˡ

  ∪-inverseʳ : RightInverse ⊤ ∁ _∪_
  ∪-inverseʳ = zipWith-inverseʳ ∨-inverseʳ

  ∪-inverse : Inverse ⊤ ∁ _∪_
  ∪-inverse = ∪-inverseˡ , ∪-inverseʳ

  ∪-distribˡ-∩ : _∪_ DistributesOverˡ _∩_
  ∪-distribˡ-∩ = zipWith-distribˡ ∨-distribˡ-∧

  ∪-distribʳ-∩ : _∪_ DistributesOverʳ _∩_
  ∪-distribʳ-∩ = zipWith-distribʳ ∨-distribʳ-∧

  ∪-distrib-∩ : _∪_ DistributesOver _∩_
  ∪-distrib-∩ = ∪-distribˡ-∩ , ∪-distribʳ-∩

  ∩-distribˡ-∪ : _∩_ DistributesOverˡ _∪_
  ∩-distribˡ-∪ = zipWith-distribˡ ∧-distribˡ-∨

  ∩-distribʳ-∪ : _∩_ DistributesOverʳ _∪_
  ∩-distribʳ-∪ = zipWith-distribʳ ∧-distribʳ-∨

  ∩-distrib-∪ : _∩_ DistributesOver _∪_
  ∩-distrib-∪ = ∩-distribˡ-∪ , ∩-distribʳ-∪

  ∪-abs-∩ : _∪_ Absorbs _∩_
  ∪-abs-∩ = zipWith-absorbs ∨-abs-∧

  ∩-abs-∪ : _∩_ Absorbs _∪_
  ∩-abs-∪ = zipWith-absorbs ∧-abs-∨

module _ (n : ℕ) where

  open AlgebraicStructures {A = Subset n} _≡_

  ∪-isMagma : IsMagma _∪_
  ∪-isMagma = record
    { isEquivalence = isEquivalence
    ; ∙-cong        = cong₂ _∪_
    }

  ∪-magma : Magma _ _
  ∪-magma = record
    { isMagma = ∪-isMagma
    }

  ∪-isSemigroup : IsSemigroup _∪_
  ∪-isSemigroup = record
    { isMagma = ∪-isMagma
    ; assoc   = ∪-assoc
    }

  ∪-semigroup : Semigroup _ _
  ∪-semigroup = record
    { isSemigroup = ∪-isSemigroup
    }

  ∪-isBand : IsBand _∪_
  ∪-isBand = record
    { isSemigroup = ∪-isSemigroup
    ; idem        = ∪-idem
    }

  ∪-band : Band _ _
  ∪-band = record
    { isBand = ∪-isBand
    }

  ∪-isSemilattice : IsSemilattice _∪_
  ∪-isSemilattice = record
    { isBand = ∪-isBand
    ; comm   = ∪-comm
    }

  ∪-semilattice : Semilattice _ _
  ∪-semilattice = record
    { isSemilattice = ∪-isSemilattice
    }

  ∪-isMonoid : IsMonoid _∪_ ⊥
  ∪-isMonoid = record
    { isSemigroup = ∪-isSemigroup
    ; identity    = ∪-identity
    }

  ∪-monoid : Monoid _ _
  ∪-monoid = record
    { isMonoid = ∪-isMonoid
    }

  ∪-isCommutativeMonoid : IsCommutativeMonoid _∪_ ⊥
  ∪-isCommutativeMonoid = record
    { isSemigroup = ∪-isSemigroup
    ; identityˡ   = ∪-identityˡ
    ; comm        = ∪-comm
    }

  ∪-commutativeMonoid : CommutativeMonoid _ _
  ∪-commutativeMonoid = record
    { isCommutativeMonoid = ∪-isCommutativeMonoid
    }

  ∪-isIdempotentCommutativeMonoid : IsIdempotentCommutativeMonoid _∪_ ⊥
  ∪-isIdempotentCommutativeMonoid = record
    { isCommutativeMonoid = ∪-isCommutativeMonoid
    ; idem                = ∪-idem
    }

  ∪-idempotentCommutativeMonoid : IdempotentCommutativeMonoid _ _
  ∪-idempotentCommutativeMonoid = record
    { isIdempotentCommutativeMonoid = ∪-isIdempotentCommutativeMonoid
    }

  ∪-∩-isLattice : IsLattice _∪_ _∩_
  ∪-∩-isLattice = record
    { isEquivalence = isEquivalence
    ; ∨-comm        = ∪-comm
    ; ∨-assoc       = ∪-assoc
    ; ∨-cong        = cong₂ _∪_
    ; ∧-comm        = ∩-comm
    ; ∧-assoc       = ∩-assoc
    ; ∧-cong        = cong₂ _∩_
    ; absorptive    = ∪-abs-∩ , ∩-abs-∪
    }

  ∪-∩-lattice : Lattice _ _
  ∪-∩-lattice = record
    { isLattice = ∪-∩-isLattice
    }

  ∪-∩-isDistributiveLattice : IsDistributiveLattice _∪_ _∩_
  ∪-∩-isDistributiveLattice = record
    { isLattice    = ∪-∩-isLattice
    ; ∨-distribʳ-∧ = ∪-distribʳ-∩
    }

  ∪-∩-distributiveLattice : DistributiveLattice _ _
  ∪-∩-distributiveLattice = record
    { isDistributiveLattice = ∪-∩-isDistributiveLattice
    }

  ∪-∩-isBooleanAlgebra : IsBooleanAlgebra _∪_ _∩_ ∁ ⊤ ⊥
  ∪-∩-isBooleanAlgebra = record
    { isDistributiveLattice = ∪-∩-isDistributiveLattice
    ; ∨-complementʳ         = ∪-inverseʳ
    ; ∧-complementʳ         = ∩-inverseʳ
    ; ¬-cong                = cong ∁
    }

  ∪-∩-booleanAlgebra : BooleanAlgebra _ _
  ∪-∩-booleanAlgebra = record
    { isBooleanAlgebra = ∪-∩-isBooleanAlgebra
    }

  ∩-∪-isLattice : IsLattice _∩_ _∪_
  ∩-∪-isLattice = L.∧-∨-isLattice ∪-∩-lattice

  ∩-∪-lattice : Lattice _ _
  ∩-∪-lattice = L.∧-∨-lattice ∪-∩-lattice

  ∩-∪-isDistributiveLattice : IsDistributiveLattice _∩_ _∪_
  ∩-∪-isDistributiveLattice = DL.∧-∨-isDistributiveLattice ∪-∩-distributiveLattice

  ∩-∪-distributiveLattice : DistributiveLattice _ _
  ∩-∪-distributiveLattice = DL.∧-∨-distributiveLattice ∪-∩-distributiveLattice

  ∩-∪-isBooleanAlgebra : IsBooleanAlgebra _∩_ _∪_ ∁ ⊥ ⊤
  ∩-∪-isBooleanAlgebra = BA.∧-∨-isBooleanAlgebra ∪-∩-booleanAlgebra

  ∩-∪-booleanAlgebra : BooleanAlgebra _ _
  ∩-∪-booleanAlgebra = BA.∧-∨-booleanAlgebra ∪-∩-booleanAlgebra

p⊆p∪q : ∀ {n p} (q : Subset n) → p ⊆ p ∪ q
p⊆p∪q (s ∷ q) here        = here
p⊆p∪q (s ∷ q) (there x∈p) = there (p⊆p∪q q x∈p)

q⊆p∪q : ∀ {n} (p q : Subset n) → q ⊆ p ∪ q
q⊆p∪q p q rewrite ∪-comm p q = p⊆p∪q p

x∈p∪q⁻ :  ∀ {n} (p q : Subset n) {x} → x ∈ p ∪ q → x ∈ p ⊎ x ∈ q
x∈p∪q⁻ (inside  ∷ p) (t       ∷ q) here          = inj₁ here
x∈p∪q⁻ (outside ∷ p) (inside  ∷ q) here          = inj₂ here
x∈p∪q⁻ (s       ∷ p) (t       ∷ q) (there x∈p∪q) =
  Sum.map there there (x∈p∪q⁻ p q x∈p∪q)

x∈p∪q⁺ : ∀ {n} {p q : Subset n} {x} → x ∈ p ⊎ x ∈ q → x ∈ p ∪ q
x∈p∪q⁺ (inj₁ x∈p) = p⊆p∪q _   x∈p
x∈p∪q⁺ (inj₂ x∈q) = q⊆p∪q _ _ x∈q

∪⇔⊎ : ∀ {n} {p q : Subset n} {x} → x ∈ p ∪ q ⇔ (x ∈ p ⊎ x ∈ q)
∪⇔⊎ = equivalence (x∈p∪q⁻ _ _) x∈p∪q⁺

------------------------------------------------------------------------
-- Lift

Lift? : ∀ {n p} {P : Pred (Fin n) p} → Decidable P → Decidable (Lift P)
Lift? P? p = decFinSubset (_∈? p) (λ {x} _ → P? x)

------------------------------------------------------------------------
-- Other

module _ {p} {P : Pred (Subset zero) p} where

  ∃-Subset-zero : ∃⟨ P ⟩ → P []
  ∃-Subset-zero ([] , P[]) = P[]

  ∃-Subset-[]-⇔ : P [] ⇔ ∃⟨ P ⟩
  ∃-Subset-[]-⇔ = equivalence ([] ,_) ∃-Subset-zero

module _ {p n} {P : Pred (Subset (suc n)) p} where

  ∃-Subset-suc : ∃⟨ P ⟩ → ∃⟨ P ∘ (inside ∷_) ⟩ ⊎ ∃⟨ P ∘ (outside ∷_) ⟩
  ∃-Subset-suc (outside ∷ p , Pop) = inj₂ (p , Pop)
  ∃-Subset-suc ( inside ∷ p , Pip) = inj₁ (p , Pip)

  ∃-Subset-∷-⇔ : (∃⟨ P ∘ (inside ∷_) ⟩ ⊎ ∃⟨ P ∘ (outside ∷_) ⟩) ⇔ ∃⟨ P ⟩
  ∃-Subset-∷-⇔ = equivalence
    [ Product.map _ id , Product.map _ id ]′
    ∃-Subset-suc

anySubset? : ∀ {p n} {P : Pred (Subset n) p} → Decidable P → Dec ∃⟨ P ⟩
anySubset? {n = zero}  P? = Dec.map ∃-Subset-[]-⇔ (P? [])
anySubset? {n = suc n} P? =
  Dec.map ∃-Subset-∷-⇔ (anySubset? (P? ∘ ( inside ∷_)) ⊎-dec
                        anySubset? (P? ∘ (outside ∷_)))

