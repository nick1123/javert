require 'spec_helper'
require "lib/file_processor"

describe FileProcessor do
  context '#tokenize_file_contents' do
    it 'break up the file into elements when given normal params' do
      input = "class Bob\n\tdef do_stuff\n\t\ti = 1\n\tend\nend\n\n"
      output = FileProcessor.tokenize_file_contents(input)
      output.size.should eq 9
      output.join("||").should eq "class||Bob||def||do_stuff||i||=||1||end||end"
    end

    it 'should not throwup when passed a nil' do
      input = nil
      output = FileProcessor.tokenize_file_contents(input)
      output.should eq []
    end
  end
  
  context "#score_file_elements" do 
    it "should correctly compute the score for elements" do
      # input = ["class", "Bob", "def", "do_stuff", "i", "=", "1", "end", "end"]
      input = ["class", "class"]
      output = FileProcessor.score_file_elements(input)
      output.is_a?(Hash).should eq true
      output.empty?.should eq true

      input = ["class", "class", "class"]
      output = FileProcessor.score_file_elements(input)
      output["class class"][:score].should eq 1

      input = ["class", "class", "class", "class"]
      output = FileProcessor.score_file_elements(input)
      output["class class"][:score].should eq 4
      output["class class class"][:score].should eq 4

      input = ["class", "class", "class", "class", "class"]
      output = FileProcessor.score_file_elements(input)
      output["class class"][:score].should eq 9
      output["class class class"][:score].should eq 16

      input = ["class", "class", "stuff", "class", "stuff", "class", "class"]
      output = FileProcessor.score_file_elements(input)
      output["class class"][:score].should eq 1
      output["stuff class"][:score].should eq 1
      output["class stuff class"][:score].should eq 4
    end
  end
  
  context "#compute_file_score" do
    it "computes a score for the file" do
      file_elements_scored = {
        "stuff class"=>{:score=>365}, 
        "class stuff"=>{:score=>97}, 
        "class stuff class"=>{:score=>754}, 
        "class class"=>{:score=>11}}
        
      output = FileProcessor.compute_file_score(file_elements_scored)
      output.should eq 1227
    end
  end 
  
  context "#score_file" do
    it "should compute the correct score for a file" do
      
    end
  end
  

end