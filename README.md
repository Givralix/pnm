# pnm

This is a basic Crystal library to parse PPM, PGM, PBM and PAM files, to make handling them easier.
It's still in development.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  pnm:
    github: givralix/pnm
```

## Usage

```crystal
require "pnm"
```

Return the file's data type:

```crystal
data = File.read(filename).bytes
PNM.datatype?(data)
```


## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/givralix/pnm/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [givralix](https://github.com/givralix) Givralix - creator, maintainer
