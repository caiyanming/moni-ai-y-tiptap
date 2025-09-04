// Type fixes for lib0@0.2.114
declare module 'lib0/diff' {
  // Completely override the module types to fix constraint issues
  export type SimpleDiff<T = any> = {
    index: number;
    remove: number;
    insert: T;
  };
  
  export function simpleDiffString(a: string, b: string): SimpleDiff<string>;
  export function simpleDiff(a: string, b: string): SimpleDiff<string>;
  export function simpleDiffArray<T>(
    a: Array<T>, 
    b: Array<T>, 
    compare?: (arg0: T, arg1: T) => boolean
  ): SimpleDiff<Array<T>>;
  export function simpleDiffStringWithCursor(a: string, b: string, cursor: number): {
    index: number;
    remove: number;
    insert: string;
  };
}