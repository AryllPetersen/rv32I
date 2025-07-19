int x = 1;
int y = 1;
int z = 1;


// fib(1) == 1, fib(3) == 2
int fib(int n){
  if(n <= 0) {
    return 0;
  }
  if(n <= 2) {
    return 1;
  }
  return fib(n-1) + fib(n-2);
}

int mul(int a, int b){
  return a * b;
}

void main(){
  x = fib(10); // 55
  y = 2 + 2;
  z = mul(7, -2);
}