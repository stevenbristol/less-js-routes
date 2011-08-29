
# Backwards compatibility for a deprecated function fix. Remove when we don't care about 1.8 breakage.
unless RUBY_VERSION =~ /^1.9/
  class Hash
    def key(k)
      self.index(k)
    end
  end
end


module Less::Js::Routes
  include Less::Js::Routes::Config
  
  def self.generate!
    s = get_js_helpers
    routes = get_routes
    
    p @_debug
    p @_ignore
    p @_only
    return true


    routes.each do |route|

# s << build_path( route.segments)
# s << "\n"
# s << route.inspect# if route.instance_variable_get(:@conditions)[:method] == :put
      s << "/////\n//#{route.inspect}\n" if @@debug
      s << <<-JS
function #{route.name}_path(#{build_params route.segments}){ #{build_default_params route.segments} return '#{build_path route.segments}';}
function #{route.name}_ajax(#{build_params route.segments, 'params'}, options){ #{build_default_params route.segments} return less_ajax('#{build_path route.segments}', verb, params, options);}
function #{route.name}_ajaxx(#{build_params route.segments, 'params'}, options){ #{build_default_params route.segments} return less_ajaxx('#{build_path route.segments}', verb, params, options);}
JS
    end
    File.open("#{Rails.public_path}/javascripts/less_routes.js", 'w') do |f|
      f.write s
    end

  end
  
  
  protected


  def self.build_params segs, others = ''
    s = []
    segs.each do |seg|
      if seg.is_a?(ActionController::Routing::DynamicSegment)
        s << seg.key.to_s.gsub(':', '')
      end
    end
    s << 'verb'
    s <<( others) unless others.blank?
    s.join(', ')
  end

  def build_default_params segs
    s = []
    segs.each do |seg|
      if seg.is_a?(ActionController::Routing::DynamicSegment)
        if seg.is_a?(ActionController::Routing::OptionalFormatSegment)
          segg = seg.key.to_s.gsub(':','')
          s << "#{segg} = less_check_format(#{segg});"
        else
          segg = seg.key.to_s.gsub(':', '')
          s << "#{segg} = less_check_parameter(#{segg});"
        end
      end
    end
    s
  end

  def self.build_path segs
    s = ""
    segs.each_index do |i|
      seg = segs[i]
      break if i == segs.size-1 && seg.is_a?(ActionController::Routing::DividerSegment)
      if seg.is_a?(ActionController::Routing::DividerSegment) || seg.is_a?(ActionController::Routing::StaticSegment)
        s << seg.instance_variable_get(:@value) 
      elsif seg.is_a?(ActionController::Routing::DynamicSegment)
        s << "' + #{seg.key.to_s.gsub(':', '')} + '"
      end
    end
    s
  end

  def self.get_params others = ''
    x = ''
    x += " + " unless x.blank? || others.blank?
    x += "less_get_params(#{others})" unless others.blank?
    x
  end

  def self.get_js_helpers
    <<-JS
function less_json_eval(json){return eval('(' +  json + ')')}  

function jq_defined(){return typeof(jQuery) != "undefined"}

function less_get_params(obj){
#{'console.log("less_get_params(" + obj + ")");' if @@debug} 
if (jq_defined()) { return obj }
if (obj == null) {return '';}
var s = [];
for (prop in obj){
s.push(prop + "=" + obj[prop]);
}
return s.join('&') + '';
}

function less_merge_objects(a, b){
#{'console.log("less_merge_objects(" + a + ", " + b + ")");' if @@debug} 
if (b == null) {return a;}
z = new Object;
for (prop in a){z[prop] = a[prop]}
for (prop in b){z[prop] = b[prop]}
return z;
}

function less_ajax(url, verb, params, options){
#{'console.log("less_ajax(" + url + ", " + verb + ", " + params +", " + options + ")");' if @@debug} 
if (verb == undefined) {verb = 'get';}
var res;
if (jq_defined()){
v = verb.toLowerCase() == 'get' ? 'GET' : 'POST'
if (verb.toLowerCase() == 'get' || verb.toLowerCase() == 'post'){p = less_get_params(params);}
else{p = less_get_params(less_merge_objects({'_method': verb.toLowerCase()}, params))} 
#{'console.log("less_merge_objects:v : " + v);' if @@debug} 
#{'console.log("less_merge_objects:p : " + p);' if @@debug} 
res = jQuery.ajax(less_merge_objects({async:false, url: url, type: v, data: p}, options)).responseText;
} else {  
new Ajax.Request(url, less_merge_objects({asynchronous: false, method: verb, parameters: less_get_params(params), onComplete: function(r){res = r.responseText;}}, options));
}
if (url.indexOf('.json') == url.length-5){ return less_json_eval(res);}
else {return res;}
}
function less_ajaxx(url, verb, params, options){
#{'console.log("less_ajax(" + url + ", " + verb + ", " + params +", " + options + ")");' if @@debug} 
if (verb == undefined) {verb = 'get';}
if (jq_defined()){
v = verb.toLowerCase() == 'get' ? 'GET' : 'POST'
if (verb.toLowerCase() == 'get' || verb.toLowerCase() == 'post'){p = less_get_params(params);}
else{p = less_get_params(less_merge_objects({'_method': verb.toLowerCase()}, params))} 
#{'console.log("less_merge_objects:v : " + v);' if @@debug} 
#{'console.log("less_merge_objects:p : " + p);' if @@debug} 
jQuery.ajax(less_merge_objects({ url: url, type: v, data: p, complete: function(r){eval(r.responseText)}}, options));
} else {  
new Ajax.Request(url, less_merge_objects({method: verb, parameters: less_get_params(params), onComplete: function(r){eval(r.responseText);}}, options));
}
}
function less_check_parameter(param) {
if (param === undefined) {
param = '';
}
return param;
}
function less_check_format(param) {
if (param === undefined) {
param = '';
} else {
param = '.'+ param;
}
return param
}
JS
  end


  def self.get_routes
    Rails.application.reload_routes!
    all_routes = Rails.application.routes.routes
    routes = all_routes.collect do |route|

      reqs = route.requirements.dup
      reqs[:to] = route.app unless route.app.class.name.to_s =~ /^ActionDispatch::Routing/
      reqs = reqs.empty? ? "" : reqs.inspect

      {:name => route.name.to_s, :verb => route.verb.to_s, :path => route.path, :reqs => reqs}
    end

    reject_routes routes

    if @@debug
      routes.each do |r|
        puts "#{r[:name]} #{r[:verb]} #{r[:path]} #{r[:reqs]}"
      end
    end
    routes
  end
  
  def reject_routes routes
    routes.reject! { |r| r[:path] =~ %r{/rails/info/properties} } # Skip the route if it's internal info route
    routes
  end

end
