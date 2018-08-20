require 'sinatra'

post '/SureOVRWebAPI/api/ovr' do
  sleep 1
  
  request.body.rewind
  a = request.body.read
  request_payload = JSON.parse a
  
  
  @request_xml = request_payload["ApplicationData"]
  Post.create!(xml_request: @request_xml, query_string: params)
  is_error = @request_xml =~ /<FirstName>ERROR<\/FirstName>/
  if is_error
     @request_xml =~ /<LastName>(.+)<\/LastName>/
     error_string = $1 || "There was an error"
     "<RESPONSE><APPLICATIONID></APPLICATIONID><APPLICATIONDATE>#{DateTime.now}</APPLICATIONDATE><SIGNATURE></SIGNATURE><ERROR>#{error_string}</ERROR></RESPONSE>"
  else
    is_invalid_penndot = /<drivers-license>88888888<\/drivers-license>/
    if is_invalid_penndot
      
"<RESPONSE><APPLICATIONID></APPLICATIONID><APPLICATIONDATE>#{DateTime.now}</APPLICATIONDATE><SIGNATURE></SIGNATURE><ERROR>VR_WAPI_InvalidOVRDL</ERROR></RESPONSE>"
    else
"<RESPONSE><APPLICATIONID>010101</APPLICATIONID><APPLICATIONDATE>#{DateTime.now}</APPLICATIONDATE><SIGNATURE></SIGNATURE><ERROR></ERROR></RESPONSE>"
    end
  end
end


get "/" do
  @posts = Post.order("created_at DESC")
  erb :"posts/index"
end