NPM=pnpm
rm -rf src patched
cp package-template.json package.json
(mkdir -p patched
cd patched
if [ ! -d @ipld/dag-json/.git ]
then
  git clone https://github.com/mabels/js-dag-json.git @ipld/dag-json
fi
if [ ! -d cborg/.git ]
then
  git clone https://github.com/mabels/cborg.git
fi
)

i=cborg
echo "Build Patched $i"
(cd patched/$i && $NPM install && $NPM run build && $NPM pack)
pnpm i -f patched/$i/*.tgz

(
i="@ipld/dag-json"
echo "Build Patched $i"
NPM=npm
(cd patched/$i && $NPM install && $NPM run build && $NPM pack)
)
pnpm i -f patched/$i/*.tgz

for i in @ipld/dag-json \
         cborg \
	 @ipld/car \
         @ipld/dag-cbor \
	 @web3-storage/pail \
 	 ipfs-unixfs-exporter 
do
	npx jscodeshift  --parser=ts  --print -t ./to-esm-transform.ts node_modules/$i/**/*.[jt]s
done

