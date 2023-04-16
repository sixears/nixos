# https://github.com/zen-kernel/zen-kernel/issues/213
{ ... }: { boot.kernelParams = [ "amdgpu.runpm=0" ]; }
