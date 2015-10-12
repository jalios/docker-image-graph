#! /bin/sh

if [ -z "$PORT" ]; then
  ruby ./image-graph-cmd.rb |ruby simplifyRules.rb  | gvpr -c 'N[$.label=="toDelete_"]{delete($G, $);}'|dot -Tpng
else
  ruby ./image-graph-web.rb
fi
