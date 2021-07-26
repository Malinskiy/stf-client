require 'spec_helper'
require 'dry/container/stub'
require 'stf/share/decision'

describe Stf::Decision do

  before :each do
    @d = Stf::Decision.new
  end

  # The first two devices should be captured immediately.
  it 'first claim' do
    expect(@d.tell_me(
        mine: 0,
        brother: 0,
        free: 1
    )).to be :take

    expect(@d.tell_me(
        mine: 1,
        brother: 0,
        free: 1
    )).to be :take
  end

  # If there are less than two free devices, then I must return.
  # Returns only agent who has more than 2 devices, and returns only the richest agent.
  # If there are several of the richest agents, then they return back lazily.
  it 'return policy' do
    expect(@d.tell_me(
        mine: 0,
        brother: 4,
        free: 0
    )).to be :nothing

    expect(@d.tell_me(
        mine: 1,
        brother: 4,
        free: 0
    )).to be :nothing

    expect(@d.tell_me(
        mine: 2,
        brother: 4,
        free: 0
    )).to be :nothing

    expect(@d.tell_me(
        mine: 4,
        brother: 3,
        free: 1
    )).to be :return

    expect(@d.tell_me(
        mine: 4,
        brother: 4,
        free: 1
    )).to be :lazyReturn

    expect(@d.tell_me(
        mine: 3,
        brother: 4,
        free: 1
    )).to be :nothing

    expect(@d.tell_me(
        mine: 3,
        brother: 0,
        free: 1
    )).to be :return

    expect(@d.tell_me(
        mine: 5,
        brother: 0,
        free: 1
    )).to be :return

    expect(@d.tell_me(
        mine: 5,
        brother: 0,
        free: 0
    )).to be :return

  end

  # If the difference with the richest agent is big (2 or more)
  # and there are free devices (no matter how much) -
  # we need to take (the brothers will share).
  it 'active taking' do
    expect(@d.tell_me(
        mine: 3,
        brother: 6,
        free: 1
    )).to be :take

    expect(@d.tell_me(
        mine: 3,
        brother: 6,
        free: 0
    )).to be :nothing

    expect(@d.tell_me(
        mine: 3,
        brother: 0,
        free: 14
    )).to be :take

    expect(@d.tell_me(
        mine: 5,
        brother: 0,
        free: 3
    )).to be :take

    expect(@d.tell_me(
        mine: 4,
        brother: 4,
        free: 20
    )).to be :take
  end

  # If the difference with the richest agent is small (actually 1) and there are more than two free devices - we need to take.
  # But if there are 2 free devices, then we do nothing, because the pool is occupied, we should wait, as long as someone returns a device voluntarily
  # (just reminder that if there are less than 2 free devices, then return rule will work, see above)
  it 'slow taking' do
    expect(@d.tell_me(
        mine: 3,
        brother: 4,
        free: 3
    )).to be :take

    expect(@d.tell_me(
        mine: 3,
        brother: 4,
        free: 2
    )).to be :nothing
  end

  # If we have equally with my brothers, and there are more than 2 free devices, we take it lazily
  # But if there are 2 free devices, then we do nothing, because the pool is occupied, we should wait, as long as someone returns a device voluntarily
  # (just reminder that if there are less than 2 free devices, then return rule will work, see above)
  it 'finish taking' do
    expect(@d.tell_me(
        mine: 4,
        brother: 4,
        free: 3
    )).to be :lazyTake

    expect(@d.tell_me(
        mine: 4,
        brother: 4,
        free: 2
    )).to be :nothing
  end

  it 'waiting' do
    expect(@d.tell_me(
        mine: 4,
        brother: 0,
        free: 2
    )).to be :nothing


    expect(@d.tell_me(
        mine: 11,
        brother: 2,
        free: 2
    )).to be :nothing

  end

end