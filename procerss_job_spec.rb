require_relative 'process_job.rb'

describe ProcessJob do
  it "should return original order with no dependencies" do
    job = ProcessJob.proccess_job("a=>,b=>,c=>")
    job.should == "abc"
  end

  it "should order based off dependencies" do
    job = ProcessJob.proccess_job("a=>,b=>c,c=>")
    job.should == "acb"
  end

  it "should return dependiency error when job depends on itself" do
    job = ProcessJob.proccess_job("a=>,b=>,c=>c")
    job.should == "error, jobs can’t depend on themselves and have circular dependencies"
  end

  it "should return circular dependency error" do
    job = ProcessJob.proccess_job("a=>,b=>c,c=>f,d=>a,e=>,f=>b")
    job.should == "error, jobs can’t have circular dependecies"
  end
end
