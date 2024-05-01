module m1

  contains

  subroutine m1s1(arg1, *, arg3)

    print*, "m1s1"

  end subroutine m1s1

  recursive subroutine m1s2(arg1)

    print*, "m1s2"

  end subroutine m1s2

  end module m1

module m2

interface
function m2if1(arg1, arg2)
end function m2if1

function m2if2(arg1, arg2, arg3, arg4)
end function m2if2
end interface

end module m2

module m3

  contains

  recursive function m1f1(arg1, arg2, arg3, arg4) result(r1)

    print*, "m1f1"

  end function m1f1

end module m3

subroutine s1(arg1, *, arg3)

print*, "s1"

end subroutine s1

program mp
implicit none

interface
function mpif1(arg1)
end function mpif1

subroutine mpis1(arg1)
end subroutine mpis1
end interface 

integer :: i

i = 1

call s()

  contains

  subroutine mps1(arg1, arg2)

    print*, "mps1"

    contains

    subroutine mps1s1(arg1, arg2, arg3)

      print*, "mps1s1"

    end subroutine mps1s1

  end subroutine mps1

end program mp
