cd OUTPUT
RMDIR DB5 /q /s
RMDIR DB9 /q /s
cd ..

for /r ".\" %%a in (.) do (
  pushd %%a
  del *.tvsconfig
  del *.res
  del *.local
  del *.identcache
  rmdir /s /q __history
  popd
)
