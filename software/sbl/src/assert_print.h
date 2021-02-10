/*
 * assert_print.h
 *
 *  Created on: 31 mars 2020
 *      Author: sriou
 */

#ifndef ASSERT_PRINT_H_
#define ASSERT_PRINT_H_

// assume print.h is included before

#ifndef ASSERT_FAIL_HANDLER
  #define ASSERT_FAIL_HANDLER(f,l) do{\
      println("exit");\
      while(1);\
    }while(0)
#endif

#define ASSERT_EQ( a,b,len) do{assert_eq (a,b,len,__FILE__,__LINE__);}while(0)
#define ASSERT_NEQ(a,b,len) do{assert_neq(a,b,len,__FILE__,__LINE__);}while(0)
#define ASSERT_EQ_VAL(a,b)  do{assert_eq_val (a,b,__FILE__,__LINE__);}while(0)
#define ASSERT_NEQ_VAL(a,b) do{assert_neq_val(a,b,__FILE__,__LINE__);}while(0)
#define ASSERT_TRUE(a)      do{assert_true(a,__FILE__,__LINE__);}while(0)

static void assert_remove_unused_warning();
static void assert_core(const void *a,const void *b, unsigned int len, const char*f,uint32_t l, int eq){
  int status = memcmp(a, b, len);
  int match = status == 0;
  if ( match != eq ){
    print_cfg(1);//force printing
    println("");
    println("ERROR: assert failed");
    if(eq) println("expected equality");
    else println("expected inequality");
    println_bytes("",a,len);
    println_bytes("",b,len);
    println(f);
    println32d("line:",l);
    #ifdef __SBL_H__
    println("enter_SBL");
    sbl_main();
    #endif
    ASSERT_FAIL_HANDLER(f,l);
    (void)assert_remove_unused_warning;
  }
}

static void assert_neq(const void *a,const void *b, unsigned int len, const char*f,uint32_t l){
  assert_core(a,b,len,f,l,0);
}

static void assert_eq(const void *a,const void *b, unsigned int len, const char*f,uint32_t l){
  assert_core(a,b,len,f,l,1);
}

static void assert_neq_val(uint64_t a, uint64_t b, const char*f,uint32_t l){
  assert_core(&a,&b,sizeof(a),f,l,0);
}

static void assert_eq_val(uint64_t a, uint64_t b, const char*f,uint32_t l){
  assert_core(&a,&b,sizeof(a),f,l,1);
}

static void assert_true(uint64_t a, const char*f,uint32_t l){
  uint64_t false64=0;
  assert_core(&a,&false64,sizeof(false64),f,l,0);
}

static void assert_remove_unused_warning(){
    (void)assert_neq;
    (void)assert_eq;
    (void)assert_neq_val;
    (void)assert_eq_val;
    (void)assert_true;
}

#endif /* ASSERT_PRINT_H_ */
