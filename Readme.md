- [ziglang](https://ziglang.org)
- [umka-lang](https://github.com/vtereshkov/umka-lang)
- It is tested using **Zig v0.15.2** and **Umka 1.5.4**.
- You need to build **Umka** and copy `umka_linux/` into this repo.
- You can test the **hello.um** script: `./umka_linux/umka hello.um`.
- Or run it from **Zig**:
```bash
❯ zig build run
info: Interpreter initialized.
info: Program compiled successfully
Hello, Sailor!
info: Program finished successfully
debug: Frame #60, dt = 0.016886079 seconds
debug: Frame #120, dt = 0.01675991 seconds
debug: Frame #180, dt = 0.016753295 seconds
debug: Frame #240, dt = 0.01676282 seconds
debug: Frame #300, dt = 0.016911458 seconds
info: Done
```
- The nice part is that once it's compiled, you can modify the
Umka script *hello.um* and run it without recompiling the
program: `./zig-out/bin/zig_umka`
