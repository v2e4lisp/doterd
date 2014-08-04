require "doterd/version"

module Doterd

  # auto draw erd at the end of current script
  #
  # Exmaple:
  #
  #   include Doterd::Autodraw
  #
  # this will also include the default erd dsl
  module Autodraw
    def self.included(base)
      base.send(:include, Doterd::DSL)

      at_exit {
        next if $! and not ($!.kind_of? SystemExit and $!.success?)
        Doterd.viz
      }
    end
  end

  # Configuration
  #
  # table_renderer should respond to call(table_name, columns)
  # relation_renderer should respond to call(relation, table_name_1, table_name_2)
  def self.config
    @config ||= {
      table_renderer: Renderer::Table,
      relation_renderer: Renderer::Relation,
      dot_filename: "/tmp/test.dot",
      output_type: :png,
      column_description: true,

      graph_attributes: {
        concentrate: true,
        labelloc: :t,
        nodesep: 0.5,
        ratio: 1.0,
        fontsize: 13,
        pad: "0.4,0.4",
        rankdir: :LR,
        margin: "0,0",
      },
      node_attributes:{
        shape: "Mrecord",
        fontsize: 15,
        margin: "0.07,0.05",
        penwidth: 1.0,
      },
      edge_attributes: {
        fontsize: 8,
        dir: :both,
        arrowsize: 1.4,
        penwidth: 1.0,
        labelangle: 32,
        labeldistance: 1.8,
        fontsize: 7,
      },
    }
  end

  # A table has the following structure
  #
  #   [
  #     table_name,
  #     {
  #       col_name_1 => [type, description]
  #       col_name_2 => [type]
  #       col_name_3 => []
  #       ...
  #     }
  #   ]
  def self.tables
    @tables ||= []
  end

  # A relation has the following structure
  #
  #   [relation_name, table_name_1, table_name_2]
  #
  # Available relation_name:
  #
  #   [:_1_N, :_1_1, :_N_1, :_N_N]
  #
  # table may or may not exist in self.tables
  def self.relations
    @relations ||= []
  end

  # Create erd image
  #
  # generate a dot source code, save it to a file
  # and create a erd image out of it.
  def self.viz(dot_filename=nil)
    dot_filename ||= Doterd.config[:dot_filename]
    File.open(dot_filename, 'w') { |f| f.write dot }
    system("dot -O -T#{Doterd.config[:output_type]} #{dot_filename}")
  end

  # Generate dot source code
  def self.dot
    gattr = Doterd.config[:graph_attributes].map {|k, v| "#{k}=\"#{v}\";\n" }.join
    nattr = Doterd.config[:node_attributes].map {|k, v| "#{k}=\"#{v}\"" }.join ','
    eattr = Doterd.config[:edge_attributes].map {|k, v| "#{k}=\"#{v}\"" }.join ','
    nodes = Doterd.tables.map {|t| Doterd.config[:table_renderer].call *t }
    edges = Doterd.relations.map {|r| Doterd.config[:relation_renderer].call *r }

    dot = %Q{
        digraph adlantis_sp {
          #{gattr}
          node [#{nattr}];
          edge [#{eattr}];
          #{(nodes << '').join(";\n")}
          #{(edges << '').join(";\n")}
        }
    }
  end

  # Default renderers
  module Renderer
    class Table
      def self.call(tbl_name, columns)
        "#{tbl_name} [label=\"TABLE #{tbl_name}|#{dot_columns columns}\"]"
      end

      def self.dot_columns(columns)
        labels = columns.map {|name, opts| "#{name} #{column_label opts}"}.join("|") + "| "
      end

      def self.column_label options
        case options.size
        when 0
          ''
        when 1
          "[#{options.first}]"
        else
          desc = options.pop
          desc = '' unless ::Doterd.config[:column_description]
          "[#{options.join(', ')}]" + '\n' + desc
        end
      end
    end

    class Relation
      def self.call(relation, from, to)
        "#{from} -> #{to} #{label relation}"
      end

      def self.label(relation)
        case relation
        when :_1_1
          "[arrowhead=odot, arrowtail=odot, dir=both]"
        when :_1_N
          "[arrowhead=inv, arrowtail=odot, dir=both]"
        when :_N_1
          "[arrowhead=odot, arrowtail=inv, dir=both]"
        when :_N_N
          "[arrowhead=inv, arrowtail=inv, dir=both]"
        else
          raise "Relation not found for #{relation}"
        end
      end
    end
  end

  # Default erd dsl
  #
  # Examples:
  #
  #   # creats tables
  #   table(:t1) {
  #     col_1 Integer, "some comments"
  #     col_2 String,  "some comments"
  #     col_3 "String, Not Null", "some comments"
  #   }
  #
  #   table(:t2) {
  #     id
  #     t1_id
  #   }
  #
  #   # create table relations
  #   _1_1 :t1, :t2
  #
  module DSL

    def config(&block)
      yield Doterd.config
    end

    def table(name, &block)
      Table.new(name, &block)
    end

    [:_1_N, :_N_1, :_N_N, :_1_1].each {|rel|
      define_method(rel) {|from, to| Doterd.relations << [rel, from, to]}
    }

    class Table < ::BasicObject
      def initialize(name, &block)
        @name = name
        @columns = {}
        instance_eval &block
        ::Doterd.tables << [@name, @columns]
      end

      def method_missing(col, *options)
        @columns[col] = options
      end
    end
  end

end
