#

arbitrary is a value of type `Gen`

```
:t arbitrary
```

Get more interesting output if you tell what you expect `a` and `b` to be.

```
sample (genTuple :: Gen (Int, Float))
```
