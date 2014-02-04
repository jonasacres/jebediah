jebediah
========

Jebediah will astound you with his knowledge of names and their corresponding hashes.

### What is it?
Git commit hashes are nice. They uniquely identify the state of a repository:
  1234abc

but sometimes, it's hard to read a commit hash over the phone. 3, b, c, d and e all sound similar. It's also pretty hard to remember a hash. Jebediah creates a reversable map between commit hashes, and friendly, memorable names:
  1234abc <-> "chipperly divided snake"

### How do I use it?
`gem install jebediah`

```
$ jeb 1234abc
chipperly divided snake
```

```
$ jeb chipperly divided snake
1234abc
```
