## v0.2.0
### Jun 23, 2014

a969fda 2014-06-12 **Luca Guidi** Implemented Lotus::Utils::Kernel.Symbol

13532f5 2014-06-13 **Luca Guidi** [breaking] Implemented Lotus::Utils::Callbacks::Chain#freeze in order to prevent modification after the object has been frozen

e438da8 2014-06-13 **Luca Guidi** [breaking] All the Utils::Kernel methods will raise TypeError in case of failed coercion.

7fd90d1 2014-06-13 **Luca Guidi** Make Kernel.Pathname to raise an error when nil is passed as argument

6437791 2014-06-13 **Luca Guidi** [breaking] Make Kernel.Time to raise an error when nil is passed as argument

c7f428b 2014-06-13 **Luca Guidi** [breaking] Make Kernel.DateTime to raise an error when nil is passed as argument

ab0dc0c 2014-06-13 **Luca Guidi** [breaking] Make Kernel.Date to raise an error when nil is passed as argument

11d5c1c 2014-06-13 **Luca Guidi** [breaking] Make Kernel.Boolean to return false when nil is passed as argument

c3bcaea 2014-06-13 **Luca Guidi** [breaking] Make Kernel.String to return an empty string when nil is passed as argument

0bd3826 2014-06-13 **Luca Guidi** [breaking] Make Kernel.Float to return 0.0 when nil is passed as argument

7ce8018 2014-06-13 **Luca Guidi** [breaking] Make Kernel.Integer to return 0 when nil is passed as argument

0377326 2014-06-13 **Luca Guidi** [breaking] Make Kernel.Hash to return an empty hash when nil is passed as argument

d3b0e2a 2014-06-13 **Luca Guidi** [breaking] Make Kernel.Set to return an empty set when nil is passed as argument

cd2d1b8 2014-06-13 **Luca Guidi** [breaking] Make Kernel.Array to return an empty array when nil is passed as argument

32c15d6 2014-06-09 **Luca Guidi** Implemented Lotus::Utils::LoadPaths#freeze in order to prevent modification after the object has been frozen

2b8d8d5 2014-06-09 **Luca Guidi** Implemented Lotus::Utils::LoadPaths#initialize_copy in order to safely dup and clone

9a91222 2014-06-09 **Luca Guidi** Implemented Lotus::Utils::LoadPaths#push, also aliased as #<<

1d3d986 2014-06-08 **Luca Guidi** Use composition over inheritance for Lotus::Utils::LoadPaths

82d0af3 2014-06-08 **Luca Guidi** [breaking] Use composition over inheritance for Lotus::Utils::Callbacks::Chain

442175b 2014-06-04 **Luca Guidi** Introduced Lotus::Utils::LoadPaths

2734a87 2014-05-28 **Luca Guidi** Introduced Lotus::Utils::String#namespace, in order to return the top level Ruby namespace for the given string

a2a19e9 2014-05-10 **Luca Guidi** Support for Ruby 2.1.2

07146a1 2014-05-08 **Luca Guidi** Implemented Lotus::Utils::Kernel.Pathname

## v0.1.1
### Apr 23, 2014

c125e0c _2014-04-18_ **Luca Guidi** Implemented Lotus::Utils::Kernel.Time

b366672 _2014-04-18_ **Luca Guidi** Implemented Lotus::Utils::Kernel.DateTime

37a010f _2014-04-17_ **Luca Guidi** Implemented Lotus::Utils::Kernel.Date

484ec9d _2014-04-17_ **Luca Guidi** Implemented Lotus::Utils::Kernel.Float

69dd6eb _2014-04-16_ **Christopher Keele** Add missing stdlib Set require to ClassAttribute.

82c0f54 _2014-04-12_ **Luca Guidi** Implemented Lotus::Utils::Kernel.Boolean

48ba6fb _2014-04-11_ **Luca Guidi** Implemented Lotus::Utils::Kernel.Hash

c10d561 _2014-04-11_ **Luca Guidi** Implemented Lotus::Utils::Kernel.Set

5582e72 _2014-04-11_ **Karl Freeman** add Github contributing guidelines

012f266 _2014-04-11_ **Luca Guidi** Implemented Lotus::Utils::Kernel.String

e1a35e2 _2014-04-08_ **Luca Guidi** Implemented Lotus::Utils::Kernel.Integer

152c856 _2014-04-08_ **Luca Guidi** Implemented Lotus::Utils::Kernel.Array

## v0.1.0
### Jan 23, 2014

1212e9d _2014-01-16_ **Luca Guidi** Introduced Lotus::Utils::String#demodulize

f9badc2 _2014-01-16_ **Luca Guidi** Fix for ClassAttribute: ensure class attributes to be inherited even the subclass is defined into a different namespace

c19d26b _2014-01-07_ **Luca Guidi** Introducing Lotus::Utils::IO

0453716 _2013-08-08_ **Luca Guidi** Added Class loading mechanism

272304b _2013-08-07_ **Luca Guidi** Initial mess
