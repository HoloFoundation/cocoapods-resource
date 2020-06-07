require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Resource do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ resource }).should.be.instance_of Command::Resource
      end
    end
  end
end

