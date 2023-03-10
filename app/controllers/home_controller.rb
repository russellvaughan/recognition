require 'net/https'
require 'uri'
require 'json'
require 'base64'
require 'rest_client'
require 'aws-sdk'

class HomeController < ApplicationController
    skip_before_action :verify_authenticity_token  


    def index 
    end

    def create 
        uploaded_file = params[:image_file_data]
        salt = (Time.now.to_f * 1000).to_s
        file_name = "#{salt}-#{uploaded_file.original_filename}"
        File.open(Rails.root.join('public', 'uploads', file_name), 'wb') do |file|
            file.write(uploaded_file.read)
        
            credentials = Aws::Credentials.new(ENV['aws_client_id'], ENV['aws_client_secret'])
            client = Aws::Rekognition::Client.new region: ENV['aws_region'], credentials: credentials
            photo = file_name
            @photo_path = "/uploads/#{file_name}"
            @path = File.expand_path("public/uploads/#{photo}") # expand path relative to the current directory
            file = File.read(@path)
            if(File.zero?(@path))
                @result = {}
                return 
            end 
            attrs = {
            image: {
            bytes: file
            }
                    }

            @text_response = client.detect_text(attrs)
            @label_response = client.detect_labels(attrs)

            render "show"
        end
    end 

end
