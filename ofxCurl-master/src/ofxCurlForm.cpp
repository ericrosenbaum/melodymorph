#include "ofxCurlForm.h"
#include "ofxCurlFormType.h"
#include "ofxCurlFormTypeInput.h"
#include "ofxCurlFormTypeFile.h"

#include <iostream>

// copy response data of form post into buffer.
size_t ofxcurl_post_write_function(char* data, size_t data_size, size_t num_data_size_entries, void* userdata) {

	size_t real_num_bytes = data_size * num_data_size_entries;
	ofxCurlForm* form = static_cast<ofxCurlForm*>(userdata);
	std::copy(
		 data
		,data+real_num_bytes
		,std::back_inserter(form->post_response_buffer)
	);
	
	return real_num_bytes;
}

ofxCurlForm::ofxCurlForm(std::string sPostURL)
	:action(sPostURL)
	,post_curr(NULL)
	,post_last(NULL)
	,timeout_after_ms(2000)
{
	curl_global_init(CURL_GLOBAL_ALL);
}

ofxCurlForm::~ofxCurlForm() {	
}

ofxCurlForm& ofxCurlForm::setTimeout(int nTimeoutMillis) {
	timeout_after_ms = nTimeoutMillis;
}

ofxCurlForm& ofxCurlForm::addInput(std::string sName, std::string sValue) {
	ofxCurlFormTypeInput* input = new ofxCurlFormTypeInput(sName);
	input->setValue(sValue);
	elements.push_back(input);
	return *this;
}

ofxCurlForm& ofxCurlForm::addFile(std::string sName, std::string sFilePath) {
	ofxCurlFormTypeFile* file = new ofxCurlFormTypeFile(sName, sFilePath);
	elements.push_back(file);
	return *this;
}


// TODO: Add timeout exception throw when dns can't be resolved.
ofxCurlForm& ofxCurlForm::post() {
	// let all elements add themself to the form.
	CURL* easy_handle;
    CURLcode result;

	parseForm();
	curl_global_init(CURL_GLOBAL_ALL);
	
	// TODO: add some error handling; see this: http://curl.haxx.se/libcurl/c/postit2.html
	easy_handle = curl_easy_init();
	curl_easy_setopt(easy_handle, CURLOPT_URL, action.c_str());
    //curl_easy_setopt(easy_handle, CURLOPT_VERBOSE,CURLOPT_STDERR);

	// Remove the Expect: from header; can give problems.. (when you get a 417 error)
	struct curl_slist *header_list= NULL;
    static const char buf[] = "Expect:";
    header_list = curl_slist_append(header_list,buf);
    curl_easy_setopt(easy_handle, CURLOPT_HTTPHEADER, header_list);
	curl_easy_setopt(easy_handle, CURLOPT_TIMEOUT_MS, timeout_after_ms);
	curl_easy_setopt(easy_handle, CURLOPT_HTTPPOST, post_curr);
	curl_easy_setopt(easy_handle, CURLOPT_WRITEFUNCTION, ofxcurl_post_write_function);
	curl_easy_setopt(easy_handle, CURLOPT_WRITEDATA, this); 
	result = curl_easy_perform(easy_handle);

	// free list..
	curl_easy_cleanup(easy_handle);
	curl_formfree(post_curr);

	// throw exceptions.
	if(result == CURLE_OPERATION_TIMEOUTED) {
		throw ofxCurlException(
			"Curl timed out"
			,OFXCURL_TIMEOUT
		);
	}
	else if(result == CURLE_COULDNT_RESOLVE_HOST) {
		throw ofxCurlException(
			"Curl cannot resolve host: " +action
			,OFXCURL_CANT_RESOLVE_HOST
		);
	}
	
	return *this;
}

void ofxCurlForm::parseForm() {
	std::vector<ofxCurlFormType*>::iterator it = elements.begin();
	while(it != elements.end()) {
		(*it)->addToForm(this, &post_curr, &post_last);
		++it;
	}
}

void ofxCurlForm::cleanup() {
	std::vector<ofxCurlFormType*>::iterator it = elements.begin();
	while(it != elements.end()) {
		delete (*it);
		it = elements.erase(it);
	};
}

std::vector<char> ofxCurlForm::getPostResponseAsBuffer() {
	return post_response_buffer;
}
std::string ofxCurlForm::getPostResponseAsString() {
	std::string result;
	std::copy(post_response_buffer.begin(), post_response_buffer.end(), std::back_inserter(result));
	return result;
}