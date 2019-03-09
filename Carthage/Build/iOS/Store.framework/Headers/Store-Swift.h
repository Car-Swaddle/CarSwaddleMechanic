// Generated by Apple Swift version 4.2.1 (swiftlang-1000.11.42 clang-1000.11.45.1)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if __has_attribute(noreturn)
# define SWIFT_NORETURN __attribute__((noreturn))
#else
# define SWIFT_NORETURN
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if defined(__has_attribute) && __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility)
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if __has_feature(attribute_diagnose_if_objc)
# define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
#else
# define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
#endif
#if __has_feature(modules)
@import CoreData;
@import CoreGraphics;
@import Foundation;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="Store",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif

@class NSEntityDescription;
@class NSManagedObjectContext;

SWIFT_CLASS_NAMED("Address")
@interface Address : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end

@class Mechanic;

@interface Address (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull identifier;
@property (nonatomic, copy) NSString * _Nullable line1;
@property (nonatomic, copy) NSString * _Nullable line2;
@property (nonatomic, copy) NSString * _Nullable postalCode;
@property (nonatomic, copy) NSString * _Nullable city;
@property (nonatomic, copy) NSString * _Nullable state;
@property (nonatomic, copy) NSString * _Nullable country;
@property (nonatomic, strong) Mechanic * _Nullable mechanic;
@end


SWIFT_CLASS_NAMED("Amount")
@interface Amount : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end

@class Balance;

@interface Amount (SWIFT_EXTENSION(Store))
@property (nonatomic) NSInteger value;
@property (nonatomic, copy) NSString * _Nonnull currency;
@property (nonatomic, strong) Balance * _Nullable balanceForAvailable;
@property (nonatomic, strong) Balance * _Nullable balanceForPending;
@property (nonatomic, strong) Balance * _Nullable balanceForReserved;
@end


SWIFT_CLASS_NAMED("AutoService")
@interface AutoService : NSManagedObject
- (void)awakeFromInsert;
/// Bool value for data base usage. Reflects value found in <code>status</code>.
@property (nonatomic, readonly) BOOL isCanceled;
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end





@class User;
@class Location;
@class Price;
@class Vehicle;
@class Review;
@class ServiceEntity;

@interface AutoService (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull identifier;
@property (nonatomic, copy) NSString * _Nullable notes;
@property (nonatomic, copy) NSDate * _Nullable scheduledDate;
@property (nonatomic, copy) NSDate * _Nonnull creationDate;
@property (nonatomic, strong) User * _Nullable creator;
@property (nonatomic, strong) Mechanic * _Nullable mechanic;
@property (nonatomic, strong) Location * _Nullable location;
@property (nonatomic, strong) Price * _Nullable price;
@property (nonatomic, strong) Vehicle * _Nullable vehicle;
@property (nonatomic, strong) Review * _Nullable reviewFromUser;
@property (nonatomic, strong) Review * _Nullable reviewFromMechanic;
@property (nonatomic, copy) NSSet<ServiceEntity *> * _Nonnull serviceEntities;
@property (nonatomic, copy) NSString * _Nullable balanceTransactionID;
@end


SWIFT_CLASS_NAMED("Balance")
@interface Balance : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface Balance (SWIFT_EXTENSION(Store))
@property (nonatomic, strong) Amount * _Nonnull available;
@property (nonatomic, strong) Amount * _Nonnull pending;
@property (nonatomic, strong) Amount * _Nullable reserved;
@property (nonatomic, strong) Mechanic * _Nullable mechanic;
@end


SWIFT_CLASS_NAMED("Location")
@interface Location : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface Location (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nullable identifier;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, copy) NSString * _Nullable streetAddress;
@property (nonatomic, strong) AutoService * _Nonnull autoService;
@end


SWIFT_CLASS_NAMED("Mechanic")
@interface Mechanic : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end

@class Transaction;
@class NSSet;

@interface Mechanic (SWIFT_EXTENSION(Store))
- (void)addTransactionsObject:(Transaction * _Nonnull)value;
- (void)removeTransactionsObject:(Transaction * _Nonnull)value;
- (void)addTransactions:(NSSet * _Nonnull)values;
- (void)removeTransactions:(NSSet * _Nonnull)values;
@end

@class TemplateTimeSpan;

@interface Mechanic (SWIFT_EXTENSION(Store))
- (void)addScheduleTimeSpansObject:(TemplateTimeSpan * _Nonnull)value;
- (void)removeScheduleTimeSpansObject:(TemplateTimeSpan * _Nonnull)value;
- (void)addScheduleTimeSpans:(NSSet * _Nonnull)values;
- (void)removeScheduleTimeSpans:(NSSet * _Nonnull)values;
@end


@interface Mechanic (SWIFT_EXTENSION(Store))
- (void)addServicesObject:(AutoService * _Nonnull)value;
- (void)removeServicesObject:(AutoService * _Nonnull)value;
- (void)addServices:(NSSet * _Nonnull)values;
- (void)removeServices:(NSSet * _Nonnull)values;
@end

@class Region;
@class Stats;
@class Payout;
@class Verification;
@class TaxInfo;

@interface Mechanic (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull identifier;
@property (nonatomic) BOOL isActive;
@property (nonatomic, strong) User * _Nullable user;
@property (nonatomic, copy) NSSet<TemplateTimeSpan *> * _Nonnull scheduleTimeSpans;
@property (nonatomic, copy) NSSet<AutoService *> * _Nonnull services;
@property (nonatomic, copy) NSSet<Review *> * _Nonnull reviews;
@property (nonatomic, strong) Region * _Nullable serviceRegion;
@property (nonatomic, copy) NSDate * _Nullable dateOfBirth;
@property (nonatomic, strong) Address * _Nullable address;
@property (nonatomic, strong) Stats * _Nullable stats;
@property (nonatomic, copy) NSString * _Nullable profileImageID;
@property (nonatomic, copy) NSString * _Nullable pushDeviceToken;
@property (nonatomic, strong) Balance * _Nullable balance;
@property (nonatomic, copy) NSSet<Transaction *> * _Nonnull transactions;
@property (nonatomic, copy) NSSet<Payout *> * _Nonnull payouts;
@property (nonatomic, copy) NSString * _Nullable identityDocumentID;
@property (nonatomic, strong) Verification * _Nullable verification;
@property (nonatomic, copy) NSSet<TaxInfo *> * _Nonnull taxYears;
@end






SWIFT_CLASS_NAMED("OilChange")
@interface OilChange : NSManagedObject
- (void)awakeFromInsert;
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface OilChange (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull identifier;
@property (nonatomic, strong) ServiceEntity * _Nonnull serviceEntity;
@end


SWIFT_CLASS_NAMED("Payout")
@interface Payout : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end




@interface Payout (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull identifier;
@property (nonatomic) NSInteger amount;
@property (nonatomic, copy) NSDate * _Nonnull arrivalDate;
@property (nonatomic, copy) NSDate * _Nonnull created;
@property (nonatomic, copy) NSString * _Nonnull currency;
@property (nonatomic, copy) NSString * _Nullable payoutDescription;
@property (nonatomic, copy) NSString * _Nullable destination;
@property (nonatomic, copy) NSString * _Nonnull type;
@property (nonatomic, copy) NSString * _Nonnull method;
@property (nonatomic, copy) NSString * _Nonnull sourceType;
@property (nonatomic, copy) NSString * _Nullable statementDescriptor;
@property (nonatomic, copy) NSString * _Nullable failureMessage;
@property (nonatomic, copy) NSString * _Nullable failureCode;
@property (nonatomic, copy) NSString * _Nullable failureBalanceTransaction;
@property (nonatomic, copy) NSSet<Transaction *> * _Nonnull transactions;
@property (nonatomic, strong) Mechanic * _Nullable mechanic;
@property (nonatomic, copy) NSString * _Nullable balanceTransactionID;
@end


SWIFT_CLASS_NAMED("Price")
@interface Price : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end

@class PricePart;

@interface Price (SWIFT_EXTENSION(Store))
- (void)addPartsObject:(PricePart * _Nonnull)value;
- (void)removePartsObject:(PricePart * _Nonnull)value;
- (void)addParts:(NSSet * _Nonnull)values;
- (void)removeParts:(NSSet * _Nonnull)values;
@end


@interface Price (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull identifier;
@property (nonatomic) NSInteger totalPrice;
@property (nonatomic, copy) NSSet<PricePart *> * _Nonnull parts;
@property (nonatomic, strong) AutoService * _Nullable autoService;
@end


SWIFT_CLASS_NAMED("PricePart")
@interface PricePart : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface PricePart (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull key;
@property (nonatomic) NSInteger value;
@property (nonatomic, strong) Price * _Nonnull price;
@end


SWIFT_CLASS_NAMED("Region")
@interface Region : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface Region (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull identifier;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude;
@property (nonatomic) double radius;
@property (nonatomic, strong) Mechanic * _Nullable mechanic;
@end


SWIFT_CLASS_NAMED("Review")
@interface Review : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface Review (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull identifier;
@property (nonatomic) CGFloat rating;
@property (nonatomic, copy) NSString * _Nullable text;
@property (nonatomic, copy) NSString * _Nonnull reviewerID;
@property (nonatomic, copy) NSString * _Nonnull revieweeID;
@property (nonatomic, strong) User * _Nullable user;
@property (nonatomic, strong) Mechanic * _Nullable mechanic;
@property (nonatomic, strong) AutoService * _Nullable autoServiceFromMechanic;
@property (nonatomic, strong) AutoService * _Nullable autoServiceFromUser;
@property (nonatomic, copy) NSDate * _Nonnull creationDate;
@end


SWIFT_CLASS_NAMED("ServiceEntity")
@interface ServiceEntity : NSManagedObject
- (void)awakeFromInsert;
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface ServiceEntity (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull identifier;
@property (nonatomic, strong) AutoService * _Nonnull autoService;
/// Optional relationships to only one service type.
/// Only one of these should exist. It should be whatever the entityType is.
@property (nonatomic, strong) OilChange * _Nullable oilChange;
@end


SWIFT_CLASS_NAMED("Stats")
@interface Stats : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface Stats (SWIFT_EXTENSION(Store))
@property (nonatomic) double averageRating;
@property (nonatomic) NSInteger numberOfRatings;
@property (nonatomic) NSInteger autoServicesProvided;
@property (nonatomic, strong) Mechanic * _Nullable mechanic;
@end


SWIFT_CLASS_NAMED("TaxInfo")
@interface TaxInfo : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface TaxInfo (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull year;
@property (nonatomic) NSInteger metersDriven;
@property (nonatomic) NSInteger mechanicCostInCents;
@property (nonatomic, strong) Mechanic * _Nonnull mechanic;
@end


SWIFT_CLASS_NAMED("TemplateTimeSpan")
@interface TemplateTimeSpan : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface TemplateTimeSpan (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull identifier;
/// The second of the day
@property (nonatomic) int64_t startTime;
/// The number of seconds
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, strong) Mechanic * _Nonnull mechanic;
@end


SWIFT_CLASS_NAMED("Transaction")
@interface Transaction : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end



@class NSNumber;
@class TransactionMetadata;

@interface Transaction (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull identifier;
@property (nonatomic) NSInteger amount;
@property (nonatomic, copy) NSDate * _Nonnull created;
@property (nonatomic, copy) NSString * _Nonnull currency;
@property (nonatomic, copy) NSString * _Nullable transactionDescription;
@property (nonatomic, strong) NSNumber * _Nullable exchangeRate;
@property (nonatomic) NSInteger fee;
@property (nonatomic) NSInteger net;
@property (nonatomic, copy) NSString * _Nonnull source;
@property (nonatomic, copy) NSString * _Nonnull type;
@property (nonatomic, strong) Mechanic * _Nullable mechanic;
@property (nonatomic, strong) Payout * _Nullable payout;
@property (nonatomic, strong) TransactionMetadata * _Nullable transactionMetadata;
@property (nonatomic, copy) NSDate * _Nonnull adjustedAvailableOnDate;
@end


SWIFT_CLASS_NAMED("TransactionMetadata")
@interface TransactionMetadata : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end

@class TransactionReceipt;

@interface TransactionMetadata (SWIFT_EXTENSION(Store))
- (void)addReceiptsObject:(TransactionReceipt * _Nonnull)value;
- (void)removeReceiptsObject:(TransactionReceipt * _Nonnull)value;
- (void)addReceipts:(NSSet * _Nonnull)values;
- (void)removeReceipts:(NSSet * _Nonnull)values;
@end


@interface TransactionMetadata (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull identifier;
@property (nonatomic, copy) NSString * _Nonnull stripeTransactionID;
@property (nonatomic) NSInteger mechanicCost;
@property (nonatomic) NSInteger drivingDistance;
@property (nonatomic, copy) NSString * _Nonnull autoServiceID;
@property (nonatomic, copy) NSString * _Nonnull mechanicID;
@property (nonatomic, copy) NSDate * _Nonnull createdAt;
@property (nonatomic, strong) Transaction * _Nullable transaction;
@property (nonatomic, strong) AutoService * _Nullable autoService;
@property (nonatomic, copy) NSSet<TransactionReceipt *> * _Nonnull receipts;
@end


SWIFT_CLASS_NAMED("TransactionReceipt")
@interface TransactionReceipt : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface TransactionReceipt (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull identifier;
@property (nonatomic, copy) NSString * _Nonnull receiptPhotoID;
@property (nonatomic, strong) TransactionMetadata * _Nullable transactionMetadata;
@property (nonatomic, copy) NSDate * _Nonnull createdAt;
@end


SWIFT_CLASS_NAMED("User")
@interface User : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface User (SWIFT_EXTENSION(Store))
- (void)addVehiclesObject:(Vehicle * _Nonnull)value;
- (void)removeVehiclesObject:(Vehicle * _Nonnull)value;
- (void)addVehicles:(NSSet * _Nonnull)values;
- (void)removeVehicles:(NSSet * _Nonnull)values;
@end


@interface User (SWIFT_EXTENSION(Store))
- (void)addServicesObject:(AutoService * _Nonnull)value;
- (void)removeServicesObject:(AutoService * _Nonnull)value;
- (void)addServices:(NSSet * _Nonnull)values;
- (void)removeServices:(NSSet * _Nonnull)values;
@end


@interface User (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull identifier;
@property (nonatomic, copy) NSString * _Nullable firstName;
@property (nonatomic, copy) NSString * _Nullable lastName;
@property (nonatomic, copy) NSString * _Nullable phoneNumber;
@property (nonatomic) CGFloat averageRating;
@property (nonatomic, copy) NSSet<AutoService *> * _Nonnull services;
@property (nonatomic, copy) NSSet<Vehicle *> * _Nonnull vehicles;
@property (nonatomic, copy) NSSet<Review *> * _Nonnull reviews;
@property (nonatomic, strong) Mechanic * _Nullable mechanic;
@property (nonatomic, copy) NSString * _Nullable profileImageID;
@property (nonatomic, copy) NSString * _Nullable email;
@property (nonatomic) BOOL isPhoneNumberVerified;
@property (nonatomic) BOOL isEmailVerified;
@property (nonatomic, copy) NSString * _Nullable pushDeviceToken;
@property (nonatomic, copy) NSString * _Nullable timeZone;
@end


SWIFT_CLASS_NAMED("Vehicle")
@interface Vehicle : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end



@class VehicleDescription;

@interface Vehicle (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSDate * _Nonnull creationDate;
@property (nonatomic, copy) NSString * _Nonnull identifier;
@property (nonatomic, copy) NSString * _Nonnull name;
@property (nonatomic, strong) User * _Nullable user;
@property (nonatomic, copy) NSSet<AutoService *> * _Nonnull autoServices;
/// At least one of licensePlate or vin or vehicleDescription must not be nil.
@property (nonatomic, copy) NSString * _Nullable vin;
@property (nonatomic, copy) NSString * _Nullable licensePlate;
@property (nonatomic, strong) VehicleDescription * _Nullable vehicleDescription;
@end


SWIFT_CLASS_NAMED("VehicleDescription")
@interface VehicleDescription : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface VehicleDescription (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull make;
@property (nonatomic, copy) NSString * _Nonnull model;
@property (nonatomic, copy) NSString * _Nonnull year;
@property (nonatomic, copy) NSString * _Nonnull trim;
@property (nonatomic, copy) NSString * _Nullable style;
@property (nonatomic, strong) Vehicle * _Nonnull vehicle;
@end


SWIFT_CLASS_NAMED("Verification")
@interface Verification : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end

@class VerificationField;

@interface Verification (SWIFT_EXTENSION(Store))
- (void)addFieldsObject:(VerificationField * _Nonnull)value;
- (void)removeFieldsObject:(VerificationField * _Nonnull)value;
- (void)addFields:(NSSet * _Nonnull)values;
- (void)removeFields:(NSSet * _Nonnull)values;
@end


@interface Verification (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nullable disabledReason;
@property (nonatomic, copy) NSDate * _Nullable dueByDate;
@property (nonatomic, copy) NSSet<VerificationField *> * _Nonnull fields;
@property (nonatomic, strong) Mechanic * _Nullable mechanic;
@end


SWIFT_CLASS_NAMED("VerificationField")
@interface VerificationField : NSManagedObject
- (nonnull instancetype)initWithEntity:(NSEntityDescription * _Nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * _Nullable)context OBJC_DESIGNATED_INITIALIZER;
@end


@interface VerificationField (SWIFT_EXTENSION(Store))
@property (nonatomic, copy) NSString * _Nonnull value;
@property (nonatomic, strong) Verification * _Nullable verification;
@end

#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#pragma clang diagnostic pop
