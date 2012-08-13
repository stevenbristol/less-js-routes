
require 'less-js-routes/config'


# Backwards compatibility for a deprecated function fix. Remove when we don't care about 1.8 breakage.
unless RUBY_VERSION =~ /^1.9/
  class Hash
    def key(k)
      index(k)
    end
  end
end


module Less::Js::Routes
  include Less::Js::Routes::Config
  
class << self
  def config
    Config.config
  end
  
  def generate!
    log_config
    s = get_js_helpers
    routes = get_routes
    

    routes.each do |route|
      
      
      
      if config.internal_debug
        p "***"
        p route
        p build_funciton_call route, 'path'
        p build_funciton_call route, 'ajax'
      end
      
      s += build_funciton_call route, 'path'
      s += "\n"
      s += build_funciton_call route, 'ajax'
      s += "\n"
    end
    File.open("#{Rails.public_path}/javascripts/less_routes.js", 'w') do |f|
      f.write s
    end

  end
  
  
  protected
  
  def build_funciton_call route, type = 'path'
    func = "function #{route[:name]}_#{type}"
    func << build_params( route, type)
    func << build_body( route, type)
  end
  
  
  def path_segments path
    path.split( '/').reject{|str| str.blank?}
  end
  
  def param_segment? segment
    segment.starts_with? ':'
  end
  
  def param_segments path
    path_segments(path).reject{|segment| !segment.starts_with? ':'}.map{|seg| seg.gsub(':', '')}
  end
  
  def build_params route, type
    s = []
    s << param_segments( route[:path])
    s << "format"
    if type == 'ajax'
      s << "verb"
      s << "params"
      s << "options"
    end
    "(#{s.reject{|x| x.blank?}.join(", ")})"
  end


  def build_body route, type
    s = ["{ "]
    param_segments(route[:path]).each do |segment|
      s << "var _#{segment} = less_check_parameter(#{segment});"
    end
    s << "var _format = less_check_format(format);"
    s << "return "
    s << "less_ajax(" if type == 'ajax'
    s1 = []
    s1 << build_path_with_variables( route[:path])
    s1 << %w(verb params options) if type == 'ajax'
    s << s1.reject{|str| str.blank?}.join(", ")
    s << ")" if type == 'ajax'
    s << "}"
    s.join
  end
  
  def build_path_with_variables path
    s = []
    path_segments(path).each do |segment|
      if param_segment? segment
        s << "'/'"
        s << "_#{segment.gsub(':', '')}"
      else
        s << "'/#{segment}'"
      end
    end
    s << "_format"
    s.join(" + ")
  end



  def get_js_helpers
    <<-JS
function less_json_eval(json){return eval('(' +  json + ')')}  

function jq_defined(){return typeof(jQuery) != "undefined"}

function less_get_params(obj){
#{'console.log("less_get_params(" + obj + ")");' if config.debug} 
if (jq_defined()) { return obj }
if (obj == null) {return '';}
var s = [];
for (prop in obj){
s.push(prop + "=" + obj[prop]);
}
return s.join('&') + '';
}

function less_merge_objects(a, b){
#{'console.log("less_merge_objects(" + a + ", " + b + ")");' if config.debug} 
if (b == null) {return a;}
z = new Object;
for (prop in a){z[prop] = a[prop]}
for (prop in b){z[prop] = b[prop]}
return z;
}

function less_ajax(url, verb, params, options){
#{'console.log("less_ajax(" + url + ", " + verb + ", " + params +", " + options + ")");' if config.debug} 
if (verb == undefined) {verb = 'get';}
if (options == undefined) {options = {}};
var done = function(r){eval(r.responseText)};
var error = function(r, status, error_thrown){alert(status + ": " + error_thrown)}
if (jq_defined()){
v = verb.toLowerCase() == 'get' ? 'GET' : 'POST'
if (verb.toLowerCase() == 'get' || verb.toLowerCase() == 'post'){p = less_get_params(params);}
else{p = less_get_params(less_merge_objects({'_method': verb.toLowerCase()}, params))} 
#{'console.log("less_merge_objects:v : " + v);' if config.debug} 
#{'console.log("less_merge_objects:p : " + p);' if config.debug} 
if (options['success'] == undefined && options['complete'] == undefined) {options['success'] = done}
if (options['error'] == undefined) {options['error'] = error;}
#{'console.log("options: " + options);' if config.debug}
jQuery.ajax(less_merge_objects({ url: url, type: v, data: p}, options));
} else {  
if (options['onSuccess'] == undefined && options['onComplete'] == undefined) {options['onComplete'] = done}
if (options['onFailure'] == undefined) {options['onFailure'] = error;}
new Ajax.Request(url, less_merge_objects({method: verb, parameters: less_get_params(params)}, options));
}
}
function less_check_parameter(param) {
if (param === undefined) {
param = '';
}
return param;
}
function less_check_format(param) {
if (param === undefined || param == '') {
param = '';
} else {
param = '.'+ param;
}
return param
}
JS
  end


  def get_routes
    Rails.application.reload_routes!
    all_routes = Rails.application.routes.routes
    routes = all_routes.collect do |route|

      reqs = route.requirements.dup
      reqs[:to] = route.app unless route.app.class.name.to_s =~ /^ActionDispatch::Routing/

      {
        :name => route.name.to_s, 
        :verb => route.verb.to_s, 
        :path => route.path.spec.to_s.gsub("(.:format)", ''), 
        :reqs => reqs
      }
    end

    reject_routes routes

    log do |writer|
      routes.each do |r|
        writer.call "#{r[:name]} #{r[:verb]} #{r[:path]} #{r[:reqs]}"
      end
    end
    routes
  end
  
  def reject_routes routes
    routes.reject! { |r| r[:path] =~ %r{/rails/info/properties} } # Skip the route if it's internal info route
    routes.reject! { |r| r[:name].blank?}
    [config.ignore].flatten.each do |rule|
      if rule.is_a? Regexp
        routes.reject! {|r| 
          r[:reqs][:controller] =~ rule}
      else
        routes.reject! {|r| r[:reqs][:controller] == rule.to_s}
      end
    end
    routes.reject! do |r|
      ![config.only].flatten.any? do |rule|
        if rule.is_a? Regexp
          r[:reqs][:controller] =~ rule
        else
          r[:reqs][:controller] == rule.to_s
        end
      end
    end
    routes
  end
  
  
  def log_config
    s = []
    s << "Debug Loging Less Js Routes with these config options:"
    config.config.each do |k, v|
      next if k.to_s == "internal_debug"
      s << "#{k}: #{v.inspect}"
    end
    log s.join("\n")
  end
  
  def log str = ''
    return unless config.debug
    if block_given?
      yield lambda {|str| puts str}
    else
      puts str
    end
  end
end
end
