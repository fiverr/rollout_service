class ScriptAPI < Grape::API

  get '/' do
    feature_name = params[:feature_name]
    feature = $rollout.get(feature_name)
    return Response.new({},'No script for this feature') unless feature.data && feature.data['script']
    script = Script.unserialized(feature.data['script'])
    Response.new(script.as_json)
  end

  post '/' do
    script_steps =  params[:scriptSteps]
    feature_name = params[:feature_name]
    script_steps.map! do |step|
      ScriptStep.new(time: step['time'], rollout_value: step['rolloutValue'])
    end

    script = Script.new(script_steps: script_steps)
    error!('Bad parameters', 400) unless script.validate

    script.script_steps.sort! {|x,y| x.time <=> y.time }
    response =  $rollout.set_feature_data(feature_name,  {script: Script.serialized(script)})
    Response.new({},response)
  end

  delete '/' do
    response = $rollout.remove_group(group)
    Response.new(response)
  end
end
