require 'less'

# Backwards compatibility for a deprecated function fix. Remove when we don't care about 1.8 breakage.
unless RUBY_VERSION =~ /^1.9/
  class Hash
    def key(k)
      self.index(k)
    end
  end
end

module Less
  class JsRoutes
    class << self
      
      
      @@debug = false


      def build_params route, others = ''
        s = []
        route.conditions[:path_info].captures.each do |cap|
          if cap.is_a?(Rack::Mount::GeneratableRegexp::DynamicSegment)
            s << cap.name.to_s.gsub(':', '')
          end
        end
        s << 'verb'
        s <<( others) unless others.blank?
        s.join(', ')
      end

      def build_default_params route
        s = []
        route.conditions[:path_info].captures.each do |cap|
          if cap.is_a?(Rack::Mount::GeneratableRegexp::DynamicSegment)
            segg = cap.name.to_s.gsub(':', '')
            s << "#{segg} = LessJsRoutes.less_check_parameter(#{segg});"
          end
        end
        s
      end

      def build_path route
        s = route.path.dup
        
        route.conditions[:path_info].captures.each do |cap|
          if route.conditions[:path_info].required_params.include?(cap.name)
            s.gsub!(/:#{cap.name.to_s}/){ "' + #{cap.name.to_s.gsub(':','')} + '" }
          else
            s.gsub!(/\((\.)?:#{cap.name.to_s}\)/){ "#{$1}' + #{cap.name.to_s.gsub(':','')} + '" }
          end
        end
        s
      end

      def get_params others = ''
        x = ''
        x += " + " unless x.blank? || others.blank?
        x += "LessJsRoutes.less_get_params(#{others})" unless others.blank?
        x
      end

      def get_js_helpers
        <<-JS
  less_json_eval: function(json){return eval('(' +  json + ')');},

  jq_defined: function(){return typeof(jQuery) != "undefined";},

  less_get_params: function(obj){
    #{'console.log("LessJsRoutes.less_get_params(" + obj + ")");' if @@debug} 
    if (jq_defined()) { return obj; }
    if (obj == null) {return '';}
    var s = [];
    for (prop in obj){
      s.push(prop + "=" + obj[prop]);
    }
    return s.join('&') + '';
  },

  less_merge_objects: function(a, b){
    #{'console.log("LessJsRoutes.less_merge_objects(" + a + ", " + b + ")");' if @@debug}
    if (b == null) {return a;}
    z = new Object;
    for (prop in a){z[prop] = a[prop];}
    for (prop in b){z[prop] = b[prop];}
    return z;
  },

  less_ajax: function(url, verb, params, options){
    #{'console.log("LessJsRoutes.less_ajax(" + url + ", " + verb + ", " + params +", " + options + ")");' if @@debug} 
    if (verb == undefined) {verb = 'get';}
    var res;
    if (jq_defined()){
      v = verb.toLowerCase() == 'get' ? 'GET' : 'POST';
      if (verb.toLowerCase() == 'get' || verb.toLowerCase() == 'post'){p = LessJsRoutes.less_get_params(params);}
      else{p = LessJsRoutes.less_get_params(LessJsRoutes.less_merge_objects({'_method': verb.toLowerCase()}, params));} 
      #{'console.log("LessJsRoutes.less_merge_objects:v : " + v);' if @@debug} 
      #{'console.log("LessJsRoutes.less_merge_objects:p : " + p);' if @@debug} 
      res = jQuery.ajax(LessJsRoutes.less_merge_objects({async:false, url: url, type: v, data: p}, options)).responseText;
    } else {  
      new Ajax.Request(url, LessJsRoutes.less_merge_objects({asynchronous: false, method: verb, parameters: LessJsRoutes.less_get_params(params), onComplete: function(r){res = r.responseText;}}, options));
    }
    if (url.indexOf('.json') == url.length-5){ return LessJsRoutes.less_json_eval(res);}
    else {return res;}
  },

  less_ajaxx: function(url, verb, params, options){
    #{'console.log("less_ajax(" + url + ", " + verb + ", " + params +", " + options + ")");' if @@debug} 
    if (verb == undefined) {verb = 'get';}
    if (jq_defined()){
      v = verb.toLowerCase() == 'get' ? 'GET' : 'POST';
      if (verb.toLowerCase() == 'get' || verb.toLowerCase() == 'post'){p = LessJsRoutes.less_get_params(params);}
      else{p = less_get_params(LessJsRoutes.less_merge_objects({'_method': verb.toLowerCase()}, params));}
      #{'console.log("LessJsRoutes.less_merge_objects:v : " + v);' if @@debug} 
      #{'console.log("LessJsRoutes.less_merge_objects:p : " + p);' if @@debug} 
      jQuery.ajax(LessJsRoutes.less_merge_objects({ url: url, type: v, data: p, complete: function(r){eval(r.responseText)}}, options));
    } else {  
      new Ajax.Request(url, LessJsRoutes.less_merge_objects({method: verb, parameters: LessJsRoutes.less_get_params(params), onComplete: function(r){eval(r.responseText);}}, options));
    }
  },

  less_check_parameter: function(param) {
    if (param === undefined) {
      param = '';
    }
    return param;
  },
  
  less_check_path: function(path) {
    return path.replace(/\\.$/m, '');
  },
JS
      end




      def generate!
        s = "LessJsRoutes = {\n\n"
        s << get_js_helpers
        
        ActionController::Routing::Routes.named_routes.routes.each do |name, route|
          # s << build_path( route.segments)
          # s << "\n"
          # s << route.inspect# if route.instance_variable_get(:@conditions)[:method] == :put
            
          s << "/////\n//#{route}\n" if @@debug
            
          s << <<-JS
  
  // #{route.name} => #{route.path}
  #{name.to_s}_path: function(#{build_params route}){ #{build_default_params route} return LessJsRoutes.less_check_path('#{build_path route}');},
  #{name.to_s}_ajax: function(#{build_params route, 'params'}, options){ #{build_default_params route} return LessJsRoutes.less_ajax(LessJsRoutes.less_check_path('#{build_path route}'), verb, params, options);},
  #{name.to_s}_ajaxx: function(#{build_params route, 'params'}, options){ #{build_default_params route} return LessJsRoutes.less_ajaxx(LessJsRoutes.less_check_path('#{build_path route}'), verb, params, options);},
  JS
        end
        s << "\n}"
        
        File.open("#{Rails.public_path}/javascripts/less_routes.js", 'w') do |f|
          f.write s
        end
      end

    end
  end
end
