/**
 * Compile-time proofs that two things are exactly the same.
 *
 * The keys of a payload shape and the interface that describes it are two
 * spellings of one fact, and a shape is exactly the kind of fact that drifts:
 * somebody adds a field to the interface and forgets the list, or renames a
 * key in one runtime and not the other. A test that compares two lists finds
 * that, but only after the build; these catch it in the editor.
 *
 * `Equal` is the standard trick: it compares the two types by asking whether
 * a function returning one is assignable to a function returning the other,
 * which is true only when they are identical and not merely compatible.
 */

/** True when `X` and `Y` are the same type, not just mutually assignable. */
export type Equal<X, Y> =
	(<T>() => T extends X ? 1 : 2) extends <T>() => T extends Y ? 1 : 2 ? true : false;

/** Fails to compile unless `T` is `true`. */
export type Expect<T extends true> = T;
