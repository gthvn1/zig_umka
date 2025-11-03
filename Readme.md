- [ziglang](https://ziglang.org)
- [umka-lang](https://github.com/vtereshkov/umka-lang)
- It is tested using **Zig v0.15.2** and **Umka 1.5.4**.
- You need to build **Umka** and copy `umka_linux/` into this repo.
- You can test the **hello.um** script: `./umka_linux/umka hello.um`.
- Or run it from **Zig**:
```bash
❯ zig build run
info: Interpreter initialized
info: Program compiled successfully
Hello, Sailor!
info: Program finished successfully
```
- The nice part is that once it's compiled, you can modify the
Umka script *hello.um* and run it without recompiling the
program: `./zig-out/bin/zig_umka`
