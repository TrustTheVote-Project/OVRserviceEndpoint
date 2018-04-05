require 'sinatra'

post '/SureOVRWebAPI/api/ovr' do
  sleep 8
  
  request.body.rewind
  request_payload = JSON.parse request.body.read
  
  
  @request_xml = request_payload["ApplicationData"]
  Post.create!(xml_request: @request_xml)
  is_error = @request_xml =~ /<FirstName>ERROR<\/FirstName>/
  if is_error
     @request_xml =~ /<LastName>(.+)<\/LastName>/
     error_string = $1 || "There was an error"      "<RESPONSE><APPLICATIONID></APPLICATIONID><APPLICATIONDATE>#{DateTime.now}</APPLICATIONDATE><SIGNATURE></SIGNATURE><ERROR>#{error_string}</ERROR></RESPONSE>"
  else
    "<RESPONSE><APPLICATIONID>010101</APPLICATIONID><APPLICATIONDATE>#{DateTime.now}</APPLICATIONDATE><SIGNATURE></SIGNATURE><ERROR></ERROR></RESPONSE>"
  end
end


get "/" do
  @posts = Post.order("created_at DESC")
  erb :"posts/index"
end