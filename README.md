# odin-dxt_decoder

CPU DXT texture decoder.

Odin port of https://github.com/kchapelier/decode-dxt (Forked from [v_dxt_decoder](https://github.com/funatsufumiya/v_dxt_decoder).)

> [!WARNING]
> Odin port was mostly done by GitHub Copilot. Use with care.

## Install (as a odin shared module)

```bash
$ export ODIN_ROOT="$(odin root)"
$ git clone https://github.com/funatsufumiya/odin-dxt_decoder $ODIN_ROOT/shared/dxt_decoder
```

## Test

```bash
odin test tests
```
