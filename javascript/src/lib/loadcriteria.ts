import { FilterCriteria } from "./filtercriteria";
import { OrderCriteria } from "./ordercriteria";

export class LoadCriteria {
  /// <summary>
  /// How far to skip into the records? (for paging)
  /// </summary>
  public Skip?: number;
  /// <summary>
  /// How many records to take (for paging)
  /// </summary>
  public Take?: number;
  /// <summary>
  /// Any filter criteria to apply to the results
  /// </summary>
  public FilterBy: FilterCriteria[] = [];
  /// <summary>
  /// Any ordering criteria to apply to the results
  /// </summary>
  public OrderBy: OrderCriteria[] = [];
}
