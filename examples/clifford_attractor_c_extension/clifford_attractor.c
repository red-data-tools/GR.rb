# include "clifford_attractor.h"
# include <math.h>

VALUE mCliffordAttractor;

static
VALUE calc(VALUE self, VALUE m)
{
  int n = NUM2INT(m);
  double a = -1.3;
  double b = -1.3;
  double c = -1.8;
  double d = -1.9;
  double sd = 0.007;
  double s = 0.007;
  VALUE arr;
  VALUE x_arr;
  VALUE y_arr;
  
  double x_old = 0;
  double x_new;
  double y_old = 0;
  double y_new;

  x_arr = rb_ary_new2(n);
  y_arr = rb_ary_new2(n);

  for(int i = 0; i++, i < n;){
    x_new = (sin(a * y_old) + c * cos(a * x_old)) * cos(s);
    y_new = (sin(b * x_old) + d * cos(b * y_old)) * cos(s);
    rb_ary_push(x_arr, DBL2NUM(x_old));
    rb_ary_push(y_arr, DBL2NUM(y_old));
    x_old = x_new;
    y_old = y_new;
    s += sd;
  }

  arr = rb_ary_new2(2);
  rb_ary_push(arr, x_arr);
  rb_ary_push(arr, y_arr);
  return arr;
}

void Init_clifford_attractor()
{
  mCliffordAttractor = rb_define_module("CliffordAttractor");
  rb_define_module_function(mCliffordAttractor, "calc", calc, 1);
}
