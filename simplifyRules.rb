$LOAD_PATH << File.join(File.dirname(__FILE__), "Ruby-Graphviz", "lib")
require 'graphviz'

module SimplifyRules

  class  Core
    attr_accessor :nodes;
    attr_accessor :baseNodes;
      
    
    def run
      @nodes= {}
      @baseNodes = {}
      GraphViz.parse_string( $<.read, :path => "/usr/local/bin" ) { |g|
        #fixLabels(g)
        fillNodesHash(g)      
        
        baseNodes.each { |id, cnt|
          node = @nodes[id] 
          #puts "start for node #{id}:  #{node}"
          lastPathId = identifySinglePath(g, id, id)
          if( !node['out'].include?(lastPathId)) then
            deletePathElement(g, id, lastPathId)
            if(id != lastPathId) then
              g.add_edge(id, lastPathId)
            end 
          end
          
        }
        puts g.output(:dot => nil)        
      }
    end
    
    def fixLabels(graph)
      graph.each_node() { |name, node|
        if( node['label'].source == "") then
          node.set { |_n|
           _n.label = _n.id
           }
        end
      }  
    end
    
    def fillNodesHash(graph)
    
      graph.each_edge {|e|
        #puts "compute edge #{e.head_node.gsub('"',"")} #{e.tail_node.gsub('"',"")}"
        headNode = nodes[e.head_node.gsub('"',"")]
        tailNode = nodes[e.tail_node.gsub('"',"")]
        if( headNode  == nil) then
           headNode = { "in" =>[], "out" => []}
           @nodes[e.head_node.gsub('"',"")] = headNode
        end
    
        if( tailNode  == nil) then
           tailNode = { "in"=>[], "out" => []}
           @nodes[e.tail_node.gsub('"',"")] = tailNode
        end
        headNode['in'].push(e.tail_node.gsub('"',""))
        tailNode['out'].push(e.head_node.gsub('"',""))    
        if( e.tail_node  == 'base') then
          baseNodes[e.head_node.gsub('"',"")]=1;
        end
          
        #puts "compute headNode  #{headNode}"
        #puts "compute tailNode  #{tailNode}"
      }
    end
    
    def deletePathElement(graph, id, lastId)
      #puts "delete from #{id} --> #{lastId}"
      node = @nodes[id];
      if node['out'].length == 1 && id != lastId then
        deletePathElement(graph, node['out'][0], lastId);
        if ! graph.get_node(id)['label'].to_s.start_with?("\"toDelete_") && node['in'] !='base' then    
          #puts "toDelete_#{graph.get_node(id)['label']}"   
          graph.get_node(id)['label']="toDelete_"
        end 
      end               
            
    end
    
    def identifySinglePath(graph, startId,  id)
      node = @nodes[id]
      #puts "id #{id}"
      #puts "resolv id #{graph.get_node(id).id}" 
      #puts "label #{graph.get_node(id)['label']}"
      #puts "source #{graph.get_node(id)['label'].source}"
      #puts "node  #{node}"  
      #puts "node out for #{id} :  #{node['out']} #{node['out'].length} ***#{graph.get_node(id)['label'].source}*** ***#{id}*** #{graph.get_node(id)['label'].source == id}"
      if( node['out'].length != 1 || graph.get_node(id)['label'].source != id ) then
        # node should not be removed        
        # but check single path on child        
        node['out'].each {|childId, cnt|    
          childNode = @nodes[childId]
          #puts "call identify with #{cnt}  #{childId}"
          lastPathId = identifySinglePath(graph,childId, childId)
          #puts "check if delete should be done #{startId} #{lastPathId} #{childId }  #{childNode['out']}"
          if( childNode['out'].length != 0 && !childNode['out'].include?(lastPathId)) then
            deletePathElement(graph, childId, lastPathId)
            if childId != lastPathId then
              graph.add_edge(childNode['in'][0], lastPathId)
            end 
          end
        }        
        #puts "return id #{id}"
        return id
      else
        #puts "Check child #{node['out'][0]}"  
        # check out nodes to search for single path
        childId = node['out'][0]          
        lastPathId = identifySinglePath(graph, startId, childId)
        #puts "return lastPathId #{id} #{lastPathId} "
        return lastPathId
      end
      
    end
    
  end
  
end

core = SimplifyRules::Core.new
core.run

  
  
