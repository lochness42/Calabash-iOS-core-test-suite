Given(/^I can see dashboard$/) do
  dashboardView.checkStaticObjects
end

Then(/^General form section is shown$/) do
  checkShown generalInfoFormView.generalInfoForm
end

When(/^I complete (.*) section$/) do | aSection |
  section = "#{stringToInstanceFormat(aSection)}FormView"
  @cv = instance(section.to_sym)
  # Changing radio button so we can fill in Train involved part
  @cv.setTrainInvolvedTo(:yes) if @cv == instance(:trainFormView)
  # Changing radio button so we can fill in People involved part
  @cv.setPeopleInvolvedTo(:yes) if @cv == instance(:peopleFormView)
  @cv.completeForm
  wait_for_none_animating
end

Then(/^(.*) section is shown$/) do | section |
  targetSection = "#{stringToInstanceFormat(section)}FormView".to_sym
  @cv = instance(targetSection)
  checkShown @cv.infoForm
end
